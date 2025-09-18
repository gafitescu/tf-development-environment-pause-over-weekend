locals {
  lambda_function_name = "${var.environment_name}-weekend-pause-resume"
  
  default_tags = merge(var.tags, {
    Environment = var.environment_name
    Module      = "tf-development-environment-pause-over-weekend"
    Purpose     = "Weekend pause/resume automation"
  })
}

# IAM Role for Lambda function
resource "aws_iam_role" "lambda_role" {
  count = var.enable_weekend_pause ? 1 : 0
  
  name = "${local.lambda_function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = local.default_tags
}

# IAM Policy for Lambda function
resource "aws_iam_role_policy" "lambda_policy" {
  count = var.enable_weekend_pause ? 1 : 0
  
  name = "${local.lambda_function_name}-policy"
  role = aws_iam_role.lambda_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeClusters"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "rds:StopDBInstance",
          "rds:StartDBInstance",
          "rds:StopDBCluster",
          "rds:StartDBCluster",
          "rds:DescribeDBInstances",
          "rds:DescribeDBClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lambda function for pause/resume operations
resource "aws_lambda_function" "pause_resume" {
  count = var.enable_weekend_pause ? 1 : 0
  
  filename         = data.archive_file.lambda_zip[0].output_path
  function_name    = local.lambda_function_name
  role            = aws_iam_role.lambda_role[0].arn
  handler         = "index.handler"
  source_code_hash = data.archive_file.lambda_zip[0].output_base64sha256
  runtime         = "python3.9"
  timeout         = 300

  environment {
    variables = {
      ECS_CLUSTER_NAME         = var.ecs_cluster_name
      ECS_SERVICE_NAMES        = join(",", var.ecs_service_names)
      RDS_INSTANCE_IDENTIFIERS = join(",", var.rds_instance_identifiers)
      RDS_CLUSTER_IDENTIFIERS  = join(",", var.rds_cluster_identifiers)
      ENVIRONMENT_NAME         = var.environment_name
    }
  }

  tags = local.default_tags
}

# Create Lambda deployment package
data "archive_file" "lambda_zip" {
  count = var.enable_weekend_pause ? 1 : 0
  
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  
  source {
    content = file("${path.module}/lambda/pause_resume.py")
    filename = "index.py"
  }
}

# EventBridge rule for pause schedule
resource "aws_cloudwatch_event_rule" "pause_schedule" {
  count = var.enable_weekend_pause ? 1 : 0
  
  name                = "${local.lambda_function_name}-pause"
  description         = "Trigger pause of ${var.environment_name} resources"
  schedule_expression = "cron(${var.pause_schedule})"
  
  tags = local.default_tags
}

# EventBridge rule for resume schedule
resource "aws_cloudwatch_event_rule" "resume_schedule" {
  count = var.enable_weekend_pause ? 1 : 0
  
  name                = "${local.lambda_function_name}-resume"
  description         = "Trigger resume of ${var.environment_name} resources"
  schedule_expression = "cron(${var.resume_schedule})"
  
  tags = local.default_tags
}

# EventBridge target for pause
resource "aws_cloudwatch_event_target" "pause_target" {
  count = var.enable_weekend_pause ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.pause_schedule[0].name
  target_id = "PauseLambdaTarget"
  arn       = aws_lambda_function.pause_resume[0].arn

  input = jsonencode({
    action = "pause"
  })
}

# EventBridge target for resume
resource "aws_cloudwatch_event_target" "resume_target" {
  count = var.enable_weekend_pause ? 1 : 0
  
  rule      = aws_cloudwatch_event_rule.resume_schedule[0].name
  target_id = "ResumeLambdaTarget"
  arn       = aws_lambda_function.pause_resume[0].arn

  input = jsonencode({
    action = "resume"
  })
}

# Lambda permission for EventBridge (pause)
resource "aws_lambda_permission" "allow_eventbridge_pause" {
  count = var.enable_weekend_pause ? 1 : 0
  
  statement_id  = "AllowExecutionFromEventBridgePause"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pause_resume[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pause_schedule[0].arn
}

# Lambda permission for EventBridge (resume)
resource "aws_lambda_permission" "allow_eventbridge_resume" {
  count = var.enable_weekend_pause ? 1 : 0
  
  statement_id  = "AllowExecutionFromEventBridgeResume"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pause_resume[0].function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.resume_schedule[0].arn
}
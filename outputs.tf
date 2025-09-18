output "lambda_function_arn" {
  description = "ARN of the Lambda function that handles pause/resume operations"
  value       = var.enable_weekend_pause ? aws_lambda_function.pause_resume[0].arn : null
}

output "lambda_function_name" {
  description = "Name of the Lambda function that handles pause/resume operations"
  value       = var.enable_weekend_pause ? aws_lambda_function.pause_resume[0].function_name : null
}

output "pause_schedule_rule_arn" {
  description = "ARN of the EventBridge rule for pausing resources"
  value       = var.enable_weekend_pause ? aws_cloudwatch_event_rule.pause_schedule[0].arn : null
}

output "resume_schedule_rule_arn" {
  description = "ARN of the EventBridge rule for resuming resources"
  value       = var.enable_weekend_pause ? aws_cloudwatch_event_rule.resume_schedule[0].arn : null
}

output "iam_role_arn" {
  description = "ARN of the IAM role used by the Lambda function"
  value       = var.enable_weekend_pause ? aws_iam_role.lambda_role[0].arn : null
}
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.weekend_pause.lambda_function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.weekend_pause.lambda_function_name
}

output "pause_schedule_rule_arn" {
  description = "ARN of the pause schedule rule"
  value       = module.weekend_pause.pause_schedule_rule_arn
}

output "resume_schedule_rule_arn" {
  description = "ARN of the resume schedule rule"
  value       = module.weekend_pause.resume_schedule_rule_arn
}
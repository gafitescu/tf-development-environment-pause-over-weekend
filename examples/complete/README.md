# Complete Example

This example demonstrates how to use the tf-development-environment-pause-over-weekend module to automatically pause and resume ECS services and RDS instances over weekends.

## Usage

1. Update the variables in `variables.tf` to match your infrastructure
2. Run terraform commands:

```bash
terraform init
terraform plan
terraform apply
```

## Configuration

The example configures:
- ECS cluster and services to pause/resume
- RDS instances to stop/start
- Weekend schedule (Friday 6 PM to Monday 8 AM UTC)
- Custom tags for resource management

## Resources Created

- Lambda function for pause/resume operations
- EventBridge rules for scheduling
- IAM roles and policies for Lambda execution
- CloudWatch log groups for monitoring

## Customization

Modify the schedule expressions in `main.tf` to adjust the pause/resume timing:
- `pause_schedule`: When to pause resources (default: Friday 6 PM UTC)
- `resume_schedule`: When to resume resources (default: Monday 8 AM UTC)
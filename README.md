# Terraform Development Environment Weekend Pause Module

This Terraform module automatically pauses ECS services and RDS instances over weekends to reduce infrastructure costs for development, staging, and UAT environments.

## Features

- **ECS Service Management**: Automatically scales ECS services to 0 tasks during weekends
- **RDS Resource Management**: Stops RDS instances and clusters during weekends
- **Flexible Scheduling**: Customizable pause/resume schedules using cron expressions
- **Multi-Environment Support**: Can be deployed across multiple environments
- **Cost Optimization**: Reduces infrastructure costs by ~70% for weekend periods
- **Automated Recovery**: Automatically resumes resources on Monday morning

## Architecture

The module creates:
- AWS Lambda function for pause/resume operations
- EventBridge (CloudWatch Events) rules for scheduling
- IAM roles and policies for secure resource management
- CloudWatch logs for monitoring and debugging

## Usage

### Basic Example

```hcl
module "weekend_pause" {
  source = "github.com/gafitescu/tf-development-environment-pause-over-weekend?ref=v1.0.0"

  environment_name = "staging"
  
  # ECS Configuration
  ecs_cluster_name  = "staging-cluster"
  ecs_service_names = ["api-service", "web-service"]
  
  # RDS Configuration
  rds_instance_identifiers = ["staging-database"]
  
  # Schedule (UTC timezone)
  pause_schedule   = "0 18 * * 5"  # Friday 6 PM
  resume_schedule  = "0 8 * * 1"   # Monday 8 AM
  
  tags = {
    Environment = "staging"
    Project     = "cost-optimization"
  }
}
```

### Advanced Example

```hcl
module "weekend_pause" {
  source = "github.com/gafitescu/tf-development-environment-pause-over-weekend?ref=v1.0.0"

  environment_name = "development"
  
  # ECS Configuration
  ecs_cluster_name  = "dev-cluster"
  ecs_service_names = [
    "api-service",
    "web-service",
    "worker-service"
  ]
  
  # RDS Configuration
  rds_instance_identifiers = ["dev-postgres", "dev-mysql"]
  rds_cluster_identifiers  = ["dev-aurora-cluster"]
  
  # Custom schedule for different timezone
  pause_schedule     = "0 22 * * 5"  # Friday 10 PM UTC (6 PM EST)
  resume_schedule    = "0 12 * * 1"  # Monday 12 PM UTC (8 AM EST)
  schedule_timezone  = "UTC"
  
  # Conditional enabling
  enable_weekend_pause = true
  
  tags = {
    Environment   = "development"
    Project       = "cost-optimization"
    Owner         = "platform-team"
    CostCenter    = "engineering"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment_name | Name of the environment (e.g., staging, dev, uat) | `string` | n/a | yes |
| ecs_cluster_name | Name of the ECS cluster to pause/resume | `string` | `null` | no |
| ecs_service_names | List of ECS service names to pause/resume | `list(string)` | `[]` | no |
| rds_instance_identifiers | List of RDS instance identifiers to pause/resume | `list(string)` | `[]` | no |
| rds_cluster_identifiers | List of RDS cluster identifiers to pause/resume | `list(string)` | `[]` | no |
| pause_schedule | Cron expression for when to pause resources | `string` | `"0 18 * * 5"` | no |
| resume_schedule | Cron expression for when to resume resources | `string` | `"0 8 * * 1"` | no |
| schedule_timezone | Timezone for the schedule | `string` | `"UTC"` | no |
| enable_weekend_pause | Whether to enable weekend pause functionality | `bool` | `true` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| lambda_function_arn | ARN of the Lambda function that handles pause/resume operations |
| lambda_function_name | Name of the Lambda function that handles pause/resume operations |
| pause_schedule_rule_arn | ARN of the EventBridge rule for pausing resources |
| resume_schedule_rule_arn | ARN of the EventBridge rule for resuming resources |
| iam_role_arn | ARN of the IAM role used by the Lambda function |

## Examples

See the [examples](./examples/) directory for complete usage examples.

## Cost Savings

Typical cost savings for a development environment:
- **ECS Services**: ~100% savings during pause periods (no running tasks)
- **RDS Instances**: ~100% savings during pause periods (stopped instances)
- **Overall**: ~70% weekend cost reduction for compute resources

## Considerations

### ECS Services
- Services are scaled to 0 tasks during pause
- Services are scaled to 1 task during resume (configurable in future versions)
- Application load balancers remain active

### RDS Resources
- Instances are fully stopped during pause
- Automatic backups continue during stopped periods
- First startup after pause may take 2-3 minutes

### Monitoring
- All operations are logged to CloudWatch
- Lambda function includes error handling and retries
- EventBridge rules can be manually triggered for testing

## Security

The module follows AWS security best practices:
- Least privilege IAM policies
- No hardcoded credentials
- Resource-specific permissions
- CloudWatch logging for audit trails

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Update documentation
6. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues, questions, or contributions, please use the GitHub issue tracker.

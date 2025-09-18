# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-09-18

### Added
- Initial release of the tf-development-environment-pause-over-weekend module
- Support for pausing and resuming ECS services automatically
- Support for pausing and resuming RDS instances and clusters
- Configurable schedules using cron expressions
- AWS Lambda function for pause/resume operations
- EventBridge rules for automated scheduling
- Comprehensive documentation and examples
- IAM roles and policies with least privilege access
- CloudWatch logging for monitoring and debugging
- Tags support for resource management
- Conditional enabling/disabling of weekend pause functionality

### Features
- **ECS Service Management**: Automatically scales services to 0 tasks during weekends
- **RDS Resource Management**: Stops instances and clusters during weekends  
- **Flexible Scheduling**: Custom pause/resume schedules via cron expressions
- **Multi-Environment Support**: Deploy across multiple environments
- **Cost Optimization**: Reduce infrastructure costs by ~70% during weekends
- **Automated Recovery**: Resume resources automatically on Monday morning
- **Error Handling**: Robust error handling and logging in Lambda function
- **Security**: Least privilege IAM policies and secure resource access
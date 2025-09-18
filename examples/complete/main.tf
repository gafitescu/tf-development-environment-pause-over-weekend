terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "weekend_pause" {
  source = "../../"

  environment_name = var.environment_name
  
  # ECS Configuration
  ecs_cluster_name  = var.ecs_cluster_name
  ecs_service_names = var.ecs_service_names
  
  # RDS Configuration
  rds_instance_identifiers = var.rds_instance_identifiers
  rds_cluster_identifiers  = var.rds_cluster_identifiers
  
  # Schedule Configuration (UTC timezone)
  pause_schedule   = "0 18 * * 5"  # Friday 6 PM UTC
  resume_schedule  = "0 8 * * 1"   # Monday 8 AM UTC
  schedule_timezone = "UTC"
  
  # Enable/disable the weekend pause functionality
  enable_weekend_pause = true
  
  tags = {
    Project     = "Development Infrastructure"
    CostCenter  = "Engineering"
    Owner       = "Platform Team"
    Environment = var.environment_name
  }
}
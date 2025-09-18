variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
  default     = "staging"
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "staging-cluster"
}

variable "ecs_service_names" {
  description = "List of ECS service names"
  type        = list(string)
  default     = ["api-service", "web-service"]
}

variable "rds_instance_identifiers" {
  description = "List of RDS instance identifiers"
  type        = list(string)
  default     = ["staging-database"]
}

variable "rds_cluster_identifiers" {
  description = "List of RDS cluster identifiers"
  type        = list(string)
  default     = []
}
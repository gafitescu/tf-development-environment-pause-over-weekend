variable "environment_name" {
  description = "Name of the environment (e.g., staging, dev, uat)"
  type        = string
  validation {
    condition = can(regex("^[a-zA-Z0-9-_]+$", var.environment_name))
    error_message = "Environment name must contain only alphanumeric characters, hyphens, and underscores."
  }
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to pause/resume"
  type        = string
  default     = null
}

variable "ecs_service_names" {
  description = "List of ECS service names to pause/resume"
  type        = list(string)
  default     = []
}

variable "rds_instance_identifiers" {
  description = "List of RDS instance identifiers to pause/resume"
  type        = list(string)
  default     = []
}

variable "rds_cluster_identifiers" {
  description = "List of RDS cluster identifiers to pause/resume"
  type        = list(string)
  default     = []
}

variable "schedule_timezone" {
  description = "Timezone for the schedule (e.g., UTC, America/New_York)"
  type        = string
  default     = "UTC"
}

variable "pause_schedule" {
  description = "Cron expression for when to pause resources (default: Friday at 6 PM)"
  type        = string
  default     = "0 18 * * 5"
}

variable "resume_schedule" {
  description = "Cron expression for when to resume resources (default: Monday at 8 AM)"
  type        = string
  default     = "0 8 * * 1"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "enable_weekend_pause" {
  description = "Whether to enable weekend pause functionality"
  type        = bool
  default     = true
}
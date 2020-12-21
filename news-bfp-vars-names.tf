variable "scraper_cw_log_group_name" {
  type = string
  description = "Name for CloudWatch Group"
}

variable "scraper_ecs_exec_iam_role_name" {
  type = string
  description = "Name for fargate execution role"
}

variable "scraper_ecs_cluster_name" {
  type = string
  description = "Name for fargate cluster"
}

variable "scraper_ecs_task_def_family" {
  type = string
  description = "Family for fargate task definition name"
}

variable "scraper_ecs_event_iam_role_name" {
  type = string
  description = "Name for EventBridge Event IAM role"
}

variable "scraper_ecs_event_iam_role_policy_name" {
  type = string
  description = "Name for EventBridge Event IAM role policy"
}

variable "scraper_ecs_event_rule_name" {
  type = string
  description = "Name for EventBridge Event"
}

variable "scraper_ecs_cluster_sg_name" {
  type = string
  description = "Name for Fargate security group"
}

variable "beanstalk_instance_profile_name" {
  type = string
  description = "Name for Instance Profile for beanstalk"
}

variable "beanstalk_instance_profile_role_name" {
  type = string
  description = "Name for Instance Profile role for beanstalk"
}

variable "beanstalk_service_role_name" {
  type = string
  description = "Name for IAM service role for beanstalk"
}

variable "beanstalk_alb_sg_name" {
  type = string
  description = "Name for Beanstalk Application Load Balancer"
}

variable "beanstalk_application_name" {
  type = string
  description = "Name for Beanstalk Application running django"
}

variable "beanstalk_application_env_name" {
  type = string
  description = "Name for Beanstalk environment"
}

variable "postgres_sg_name" {
  type = string
  description = "Name for Postgres Security Group"
}

variable "postgres_identifier" {
  type = string
  description = "Identifier for Postgres DB"
}

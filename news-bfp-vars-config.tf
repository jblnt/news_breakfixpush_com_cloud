
#AWS CONFIG
variable "aws_config_region" {
  type = string
  description = "AWS region project will be deployed"
}

variable "aws_config_credFile" {
  type = string
  description = "AWS Credentials file"
}

variable "aws_config_profile" {
  type = string
  description = "AWS profile for access"
}

#NETWORK CONFIG
variable "vpc_id" {
  type = string
  description = "VPC ID for AWS"
  default = "vpc-7675b40b"
}

variable "vpc_subnets" {
  type = list(string)
  description = "All subnets available for required VPC"
}

#EVENTBRIDGE CONFIG
variable "platform_ver" {
  type = string
  description = "Platform version to use when calling ECS cluster"
}

variable "task_count" {
  type = number
  description = "Amount of Tasks to run in ECS cluster"
}

#ECS CONFIG

#BEANSTALK CONFIG
variable "beanstalk_instance_type" {
  type = string 
  description = "List of instance type for Beanstalk"
}

variable "beanstalk_ssl" {
  type = string 
  description = "ARN for SSL certificate for news.breakfixpush.com"
}

variable "beanstalk_django_debug" {
  type = string 
  description = "True|False to enable django debug"
}

variable "beanstalk_rds_username" {
  type = string 
  description = "Database Username for Django"
}

variable "beanstalk_rds_password" {
  type = string 
  description = "Database password for Django"
}

variable "beanstalk_django_phrase" {
  type = string 
  description = "Django secret phrase for security"
}

variable "beanstalk_allowed_urls" {
  type = string 
  description = "URLs in a string format separated by a comma for Django to allow communication from."
}

#RDS CONFIG

variable "db_storage" {
  type = number 
  description = "DB storage storage size"
}

variable "db_ingress_sgs" {
  type = list(string) 
  description = "List of security group ID used by postgres"
  default = ["sg-74fdc44a"] 
}

variable "db_instance_type" {
  type = string 
  description = "Postgres DB instance Type"
}

variable "db_master_username" {
  type = string 
  description = "Master username for Postgres DB"
}

variable "db_master_password" {
  type = string 
  description = "Master password for Postgres DB"
}

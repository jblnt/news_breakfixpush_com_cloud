terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.12.0"
    }
  }
}

provider "aws" {
  region                  = var.aws_config_region
  shared_credentials_file = var.aws_config_credFile
  profile                 = var.aws_config_profile
}


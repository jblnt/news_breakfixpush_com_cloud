#BEANSTALK CONFIG

resource "aws_iam_instance_profile" "beanstalk_instance_profile" {
  name = var.beanstalk_instance_profile_name
  role = aws_iam_role.beanstalk_instance_profile_role.name
  
}

resource "aws_iam_role" "beanstalk_instance_profile_role" {
  name = var.beanstalk_instance_profile_role_name

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "beanstalk_instance_profile_role_webTier_attach" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier" 
}

resource "aws_iam_role_policy_attachment" "beanstalk_instance_profile_role_worker_attach" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "beanstalk_instance_profile_role_docker-attach" {
  role       = aws_iam_role.beanstalk_instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker" 
}

resource "aws_iam_role" "beanstalk_service_role" {
  name = var.beanstalk_service_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "beanstalk_service_role_service_attach" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService" 
}

resource "aws_iam_role_policy_attachment" "beanstalk_service_role_health_attach" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_security_group" "beanstalk_alb_sg" {
  name = var.beanstalk_alb_sg_name
  ingress {
    description = "Allow http from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "Allow https from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = var.vpc_id
  tags = {
    Name = var.beanstalk_alb_sg_name 
  }
}

resource "aws_elastic_beanstalk_application" "beanstalk_application" {
  name        = var.beanstalk_application_name
  description = "Terraform created django application"
}

resource "aws_elastic_beanstalk_environment" "beanstalk_application_env" {
  name                = var.beanstalk_application_env_name
  application         = aws_elastic_beanstalk_application.beanstalk_application.name
  description         = "terraform created env for bfp app"
  tier                = "WebServer"
  solution_stack_name = "64bit Amazon Linux 2 v3.1.2 running Python 3.7"

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.beanstalk_service_role.arn
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_instance_profile.arn
  }
  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.beanstalk_instance_type
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerIsShared"
    value     = false
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "ManagedSecurityGroup"
    value     = aws_security_group.beanstalk_alb_sg.id
  }
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.beanstalk_alb_sg.id
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.beanstalk_ssl
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = 1
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DJANGO_DEBUG"
    value     = var.beanstalk_django_debug
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_HOSTNAME"
    value     = aws_db_instance.postgres.address
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_USERNAME"
    value     = var.beanstalk_rds_username
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "RDS_PASSWORD"
    value     = var.beanstalk_rds_password
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "DJANGO_SECRET_KEY"
    value     = var.beanstalk_django_phrase
  }
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "ALLOWED_URLS"
    value     = var.beanstalk_allowed_urls 
  }
}

#RDS CONFIG

resource "aws_security_group" "postgres_sg" {
  name = var.postgres_sg_name

  ingress {
    description     = "Allow traffic from beanstalk"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.db_ingress_sgs
  }

  ingress {
    description = "Allow traffic from thegrid"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["165.227.194.46/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = var.vpc_id 
  tags = {
    Name = var.postgres_sg_name 
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage           = var.db_storage
  allow_major_version_upgrade = false
  backup_retention_period     = 3
  delete_automated_backups    = true
  engine                      = "postgres"
  engine_version              = "12.3"
  identifier                  = var.postgres_identifier
  instance_class              = var.db_instance_type
  max_allocated_storage       = 0
  port                        = 5432
  username                    = var.db_master_username
  password                    = var.db_master_password
  skip_final_snapshot         = true
  vpc_security_group_ids      = [aws_security_group.postgres_sg.id]
  publicly_accessible         = false
}


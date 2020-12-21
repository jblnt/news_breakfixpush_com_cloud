#CLOUDWATCH LOGS

resource "aws_cloudwatch_log_group" "scraper_cw_log_group" {
  name = var.scraper_cw_log_group_name
  retention_in_days = 1
}

#ECS CONFIG

resource "aws_iam_role" "scraper_ecs_exec_iam_role" {
  name = var.scraper_ecs_exec_iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "scraper_ecs_exec_task_attach" {
  role       = aws_iam_role.scraper_ecs_exec_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "scraper_ecs_exec_s3_attach" {
  role       = aws_iam_role.scraper_ecs_exec_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_ecs_cluster" "scraper_ecs_cluster" {
  name = var.scraper_ecs_cluster_name
  capacity_providers = ["FARGATE"]
  tags = {
    Name = var.scraper_ecs_cluster_name  
  }
}

resource "aws_ecs_task_definition" "scraper_ecs_task_def" {
  family = var.scraper_ecs_task_def_family
  container_definitions = file("bfp-container.json")
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = 256
  memory = 512 
  execution_role_arn = aws_iam_role.scraper_ecs_exec_iam_role.arn
}

# EVENTBRIDGE FOR SCRAPER

resource "aws_iam_role" "scraper_ecs_event_iam_role" {
  name = var.scraper_ecs_event_iam_role_name
  assume_role_policy = <<DOC
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
DOC
}

resource "aws_iam_role_policy" "scraper_ecs_event_iam_role_policy" {
  name = var.scraper_ecs_event_iam_role_policy_name
  role = aws_iam_role.scraper_ecs_event_iam_role.id

  policy = <<DOC
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": ["iam:PassRole"],
        "Resource": ["*"]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ecs:RunTask"
        ],
        "Resource": [
            "${aws_ecs_task_definition.scraper_ecs_task_def.arn}"
        ],
        "Condition": {
            "ArnLike": {
                "ecs:cluster": "${aws_ecs_cluster.scraper_ecs_cluster.arn}"
            }
        }
    }]
}
DOC

}

resource "aws_cloudwatch_event_rule" "scraper_ecs_event_rule" {
  name = var.scraper_ecs_event_rule_name
  #schedule_expression = "cron(30 11 * * ? *)"
  schedule_expression = "cron(15 15 * * ? *)"
  description = "Call Fargate Cluster Every Day"
  
}

resource "aws_security_group" "scraper_ecs_cluster_sg" {
  name = var.scraper_ecs_cluster_sg_name 
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
    Name = var.scraper_ecs_cluster_sg_name
  }
}

resource "aws_cloudwatch_event_target" "scraper_ecs_event_target" {
  rule = aws_cloudwatch_event_rule.scraper_ecs_event_rule.id
  arn = aws_ecs_cluster.scraper_ecs_cluster.arn
  role_arn = aws_iam_role.scraper_ecs_event_iam_role.arn 

  ecs_target {
    launch_type = "FARGATE"
    network_configuration {
      subnets = var.vpc_subnets
      security_groups = [aws_security_group.scraper_ecs_cluster_sg.id] 
      assign_public_ip = true
    }
    platform_version = var.platform_ver
    task_count = var.task_count
    task_definition_arn = aws_ecs_task_definition.scraper_ecs_task_def.arn
  }
}

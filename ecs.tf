terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}


provider "aws" {
  region = "us-east-1"
}

locals {
  services = ["nginx"]
}

resource "aws_ecs_cluster" "my_cluster" {
  name = var.cluster_name
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Define your ECS task definition
resource "aws_ecs_task_definition" "nginx" {
  family                   = "nginx"
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      "name": "nginx",
      "image": "030741324211.dkr.ecr.us-east-1.amazonaws.com/hello-app:latest",
      "essential": true,
      "cpu": 2048,
      "memory": 4096,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": var.logs_group,
          "awslogs-region": var.region,
          "awslogs-stream-prefix": "nginx"
        }
      }
    }
  ])
}



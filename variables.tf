variable "cluster_name" {
  default = "will-test"
}

variable "region" {
  default = "us-east-1"
}

variable "logs_group" {
  default = "/ecs/will-test"
}

variable "ecr_repository_url" {
  default = "030741324211.dkr.ecr.us-east-1.amazonaws.com/test:latest"
}

variable "aws_account_id" {
  default = "030741324211"
}


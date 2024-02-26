resource "aws_ecs_task_definition" "nginx_task" {
  family = "nginx_task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  
  container_definitions = jsonencode([
    {
      name      = "nginx-container"
      image     = "test:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
  tags = {
    Name = "nginx-task"
  }
 }

resource "aws_ecs_service" "my-ecs-service" {
  name                 = "my-ecs-service"
  cluster              = aws_ecs_cluster.my_cluster.id
  task_definition      = aws_ecs_task_definition.nginx.arn
  launch_type          = "FARGATE"
  desired_count        = 1
  force_new_deployment = true

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.nginx_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my-ecs-service_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.nginx.arn
  }
}

resource "aws_lb" "my-ecs-service_lb" {
  name               = "my-ecs-service-lb"
  internal           = false
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.nginx_sg.id]
  load_balancer_type = "application"
}

resource "aws_lb_target_group" "my-ecs-service_tg" {
  name        = "my-ecs-service-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "my-ecs-service_listener" {
  load_balancer_arn = aws_lb.my-ecs-service_lb.arn
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-ecs-service_tg.arn
  }
}


resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.my-ecs-service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

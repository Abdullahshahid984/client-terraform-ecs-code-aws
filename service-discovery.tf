resource "aws_service_discovery_private_dns_namespace" "app"  {
  name        = "app.local"
  vpc         = module.vpc.vpc_id
  description = "Private DNS namespace for app services"
}

resource "aws_service_discovery_service" "nginx" {
  name = "nginx"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.app.id
    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
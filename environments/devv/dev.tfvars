lb_name             = "dev-ecom-alb"
loadbalancer_target = "dev-ecom-target"
load_balancer_type = "application"
target_type         = "instance"
target_group_port     = 80
target_group_protocol = "HTTP"
certificate_arn       = null
health_check_path     = "/health"
enable_access_logs   = true
access_logs_bucket   = "teleios-ecommerce-alb-logs"
access_logs_prefix   = "dev-alb"



environment  = "dev"
module_name  = "alb"

tags = {
  Project    = "E-commerce"
  Owner      = "Teleios"
}

alb_sg              = "" 
lb_name             = "dev-ecom-alb"
loadbalancer_target = "dev-ecom-target"
load_balancer_type = "application"
target_type         = "instance"
vpc_id              = "" 
public_subnets      = ["", ""] 

target_group_port     = 80
target_group_protocol = "HTTP"
certificate_arn       = null
health_check_path     = "/health"

environment  = "dev"
module_name  = "alb"

tags = {
  Project    = "E-commerce"
  Owner      = "Teleios"
}

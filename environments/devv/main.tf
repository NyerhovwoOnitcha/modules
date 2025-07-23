module "alb" {

    source = "../../modules/alb"

    
    alb_sg = var.alb_sg
    lb_name = var.lb_name
    target_type = var.target_type
    load_balancer_type = var.load_balancer_type
    target_group_port = var.target_group_port
    target_group_protocol = var.target_group_protocol
    certificate_arn = var.certificate_arn
    health_check_path = var.health_check_path
    public_subnets = var.public_subnets
    tags = var.tags
    vpc_id = var.vpc_id
    environment = var.environment
    module_name = "alb" 
    loadbalancer_target = var.loadbalancer_target
    listener_rule_priority = var.listener_rule_priority
    enable_access_logs = var.enable_access_logs
    access_logs_bucket = var.access_logs_bucket
    access_logs_prefix = var.access_logs_prefix

    listener_conditions = [
        {
            path_pattern = ["/api/*"]
            host_header  = ["dev.example.com"]
        },
        {
            path_pattern = ["/admin/*"]
        }

    ]
   
  
}


module "alb" {

    source = "../../modules/alb"

    
    lb_name = var.lb_name
    target_type = var.target_type
    load_balancer_type = var.load_balancer_type
    target_group_port = var.target_group_port
    target_group_protocol = var.target_group_protocol
    certificate_arn = var.certificate_arn
    health_check_path = var.health_check_path
    tags = var.tags
    environment = var.environment
    module_name = "alb" 
    loadbalancer_target = var.loadbalancer_target
    enable_access_logs = var.enable_access_logs
    access_logs_bucket = var.access_logs_bucket
    access_logs_prefix = var.access_logs_prefix
    alb_sg              = module.alb_security_group.alb_sg_id
    vpc_id              = module.vpc.vpc_id
    public_subnets      = module.vpc.public_subnets
    interval            = var.interval
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout

    listener_conditions = [
        {
            path_pattern = ["/api/*"]
            host_header  = ["dev.example.com"]
        },
        {
            path_pattern = ["/admin/*"]
        }

    ]

    listener_conditions = [
        {
            path_pattern = ["/api/*"]
            host_header  = ["dev.example.com"]
        },
        {
            path_pattern = ["/admin/*"]
            host_header  = ["admin.dev.example.com"]
        },
        {
            http_header = {
                name   = "X-Env"
                values = ["dev"]
            }
        }
    ]
  
}


# Create the ALB
resource "aws_lb" "terraform-aws-alb" {
  name     = var.lb_name
  internal = false
  security_groups = [var.alb_sg]
  subnets         = var.public_subnets

  ip_address_type    = "ipv4"
  load_balancer_type = var.load_balancer_type

  access_logs {
    enabled = var.enable_access_logs
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
  }

  tags = merge(
    var.tags,
    {
      Name        = var.lb_name
      Environment = var.environment
      Module      = var.module_name
    }
  )
}




# Create a target group for the ALB
resource "aws_lb_target_group" "lb-tgt" {
  health_check {
    interval            = var.interval
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.timeout
    path                = var.health_check_path
    port                = var.target_group_port
    protocol            = var.target_group_protocol

    
  }
  name        = var.loadbalancer_target
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id

  tags = merge(
  var.tags,
  {
    Name        = var.loadbalancer_target
    Environment = var.environment
    Module      = var.module_name
  }
)

}


# Create a listener for the target group
# HTTPS listener (only if protocol is HTTPS and cert provided)
resource "aws_lb_listener" "https" {
  count             = var.target_group_protocol == "HTTPS" && var.certificate_arn != null ? 1 : 0
  load_balancer_arn = aws_lb.terraform-aws-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tgt.arn
  }
}

# HTTP listener (only if protocol is HTTPS, used to redirect to HTTPS)
resource "aws_lb_listener" "http" {
  count             = var.target_group_protocol == "HTTPS" ? 1 : 0
  load_balancer_arn = aws_lb.terraform-aws-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}




# Listener rules for the ALB
resource "aws_lb_listener_rule" "lb_listener_rules" {
  for_each = {
    for idx, cond in var.listener_conditions :
    "${idx}" => cond
  }

  listener_arn = var.target_group_protocol == "HTTPS" && var.certificate_arn != null ?
    aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn

  priority = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tgt.arn
  }

  dynamic "condition" {
    for_each = [each.value]
    content {
      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", [])
        content {
          values = path_pattern.value
        }
      }

      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", [])
        content {
          values = host_header.value
        }
      }

      dynamic "http_header" {
        for_each = lookup(condition.value, "http_header", {}) == {} ? [] : [lookup(condition.value, "http_header", {})]
        content {
          http_header {
            name   = http_header.value.name
            values = http_header.value.values
          }
        }
      }
    }
  }
}


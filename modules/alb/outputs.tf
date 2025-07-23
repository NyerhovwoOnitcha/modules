output "alb_dns_name" {
  value       = aws_lb.ecom-alb.dns_name
  description = "load balancer DNS name"
}


output "nginx-tgt" {
  description = " balancer target group"
  value       = aws_lb_target_group.lb-tgt.arn
}

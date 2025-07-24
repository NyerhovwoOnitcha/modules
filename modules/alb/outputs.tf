output "alb_dns_name" {
  value       = aws_lb.terraform-aws-alb.dns_name
  description = "load balancer DNS name"
}

output "alb_zone_id" {
  value       = aws_lb.terraform-aws-alb.zone_id
  description = "The canonical hosted zone ID of the ALB"
}

output "target_group_arn" {
  value       = aws_lb_target_group.lb-tgt.arn
  description = "ARN of the target group associated with the ALB"
}
output "alb_arn" {
  value       = aws_lb.terraform-aws-alb.arn
  description = "ARN of the created Application Load Balancer"
}

output "lb-tgt" {
  description = " balancer target group"
  value       = aws_lb_target_group.lb-tgt.arn
}

output "https_listener_arn" {
  value       = length(aws_lb_listener.https) > 0 ? aws_lb_listener.https[0].arn : null
  description = "The ARN of the HTTPS listener (if created)"
}

output "http_listener_arn" {
  value       = length(aws_lb_listener.http) > 0 ? aws_lb_listener.http[0].arn : null
  description = "The ARN of the HTTP listener (if created)"
}

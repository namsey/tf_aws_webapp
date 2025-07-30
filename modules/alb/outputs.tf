output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.webapp_alb.dns_name
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.webapp_tg.arn
}


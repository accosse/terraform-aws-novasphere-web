output "alb_dns_name" {
  description = "DNS de l'ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN du target group"
  value       = aws_lb_target_group.this.arn
}

output "alb_sg_id" {
  description = "ID du Security Group ALB"
  value       = aws_security_group.this_alb.id
}

output "web_sg_id" {
  description = "ID du Security Group instances"
  value       = aws_security_group.this_web.id
}

output "asg_name" {
  description = "Nom de l'ASG"
  value       = aws_autoscaling_group.this.name
}
output "alb_dns" {
  description = "ALB DNS name"
  value       = module.alb.lb_dns_name
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.autoscaling.asg_name
}

output "tg_arn_suffix" {
  description = "Auto Scaling Group name"
  value       = module.alb.target_group_arn_suffix
}

output "alb_arn_suffix" {
  description = "Auto Scaling Group name"
  value       = module.alb.lb_arn_suffix
}
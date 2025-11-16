output "alb_dns" {
  description = "ALB DNS name"
  value       = module.alb.lb_dns_name
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = module.autoscaling.asg_name
}

output "tg_name" {
  description = "Auto Scaling Group name"
  value       = module.alb.target_group_name
}
output "lb_dns_name" {
  value = aws_lb.app.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn_suffix
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "target_group_name" {
  value = aws_lb_target_group.tg.name
}
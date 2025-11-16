output "lb_dns_name" {
  value = aws_lb.app.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.tg.arn
}
output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}
output "target_group_arn_suffix" {
  value = aws_lb_target_group.tg.arn_suffix
}
output "lb_arn_suffix" {
  value = aws_lb.app.arn_suffix
}
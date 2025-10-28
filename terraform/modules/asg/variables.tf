variable "vpc_id" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "target_group_arn" {
  type = string
}
variable "key_name" {
  type = string
  default = "spl"
}
variable "instance_type" {
  type = string
}
variable "desired_capacity" {
  type = number
}
variable "min_size" {
  type = number
}
variable "max_size" {
  type = number
}
variable "alb_sg_id" {
  type = string
}
variable "ssh_allowed_cidrs" {
  type = list(string)
  default = ["0.0.0.0/0"]
}
variable "index_message" {
  type = string
  default = "Hello from autoscaled EC2!"
}

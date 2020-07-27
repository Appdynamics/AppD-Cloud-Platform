output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "aws_ec2_enterprise_console_hostname_prefix" {
  description = "AWS EC2 Enterprise Console hostname prefix."
  value       = var.aws_ec2_enterprise_console_hostname_prefix
}

output "aws_ec2_controller_hostname_prefix" {
  description = "AWS EC2 Controller hostname prefix."
  value       = var.aws_ec2_controller_hostname_prefix
}

output "aws_ec2_events_service_hostname_prefix" {
  description = "AWS EC2 Events Service hostname prefix."
  value       = var.aws_ec2_events_service_hostname_prefix
}

output "aws_ec2_eum_server_hostname_prefix" {
  description = "AWS EC2 EUM Server hostname prefix."
  value       = var.aws_ec2_eum_server_hostname_prefix
}
output "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  value       = var.aws_ec2_domain
}

output "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  value       = var.aws_ec2_user_name
}

output "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  value       = var.aws_ec2_instance_type
}

output "ids" {
  description = "List of IDs of instances."
  value       = flatten([toset(module.enterprise_console.id), toset(module.controller.id), toset(module.events_service.id), toset(module.eum_server.id)])
}

output "private_ips" {
  description = "List of private IP addresses assigned to the instances."
  value       = flatten([toset(module.enterprise_console.private_ip), toset(module.controller.private_ip), toset(module.events_service.private_ip), toset(module.eum_server.private_ip)])
}

output "public_ips" {
  description = "List of public IP addresses assigned to the instances."
  value       = flatten([toset(module.enterprise_console.public_ip), toset(module.controller.public_ip), toset(module.events_service.public_ip), toset(module.eum_server.public_ip)])
}
output "public_dns" {
  description = "List of public DNS names assigned to the instances."
  value       = flatten([toset(module.enterprise_console.public_dns), toset(module.controller.public_dns), toset(module.events_service.public_dns), toset(module.eum_server.public_dns)])
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances."
  value       = flatten([toset(module.enterprise_console.vpc_security_group_ids), toset(module.controller.vpc_security_group_ids), toset(module.events_service.vpc_security_group_ids), toset(module.eum_server.vpc_security_group_ids)])
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances."
  value       = flatten([toset(module.enterprise_console.root_block_device_volume_ids), toset(module.controller.root_block_device_volume_ids), toset(module.events_service.root_block_device_volume_ids), toset(module.eum_server.root_block_device_volume_ids)])
}

output "tags" {
  description = "List of tags."
  value       = module.enterprise_console.tags
}

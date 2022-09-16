# Outputs ------------------------------------------------------------------------------------------
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
  value       = flatten([module.enterprise_console.id, toset(flatten([for vm in module.controller : vm.id])), toset(flatten([for vm in module.events_service : vm.id])), module.eum_server.id])
}

output "private_ips" {
  description = "List of private IP addresses assigned to the instances."
  value       = flatten([module.enterprise_console.private_ip, toset(flatten([for vm in module.controller : vm.private_ip])), toset(flatten([for vm in module.events_service : vm.private_ip])), module.eum_server.private_ip])
}

output "public_ips" {
  description = "List of public IP addresses assigned to the instances."
  value       = flatten([module.enterprise_console.public_ip, toset(flatten([for vm in module.controller : vm.public_ip])), toset(flatten([for vm in module.events_service : vm.public_ip])), module.eum_server.public_ip])
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances."
  value       = flatten([module.enterprise_console.public_dns, toset(flatten([for vm in module.controller : vm.public_dns])), toset(flatten([for vm in module.events_service : vm.public_dns])), module.eum_server.public_dns])
# value       = flatten([toset(module.enterprise_console.public_dns), toset(flatten([for vm in module.controller : vm.public_dns])), toset(flatten([for vm in module.events_service : vm.public_dns])), toset(module.eum_server.public_dns)])
}

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "vpc_azs" {
  description = "A list of availability zones specified as arguments to this VPC module."
  value       = module.vpc.azs
}

output "vpc_public_subnet_ids" {
  description = "A list of IDs of public subnets."
  value       = tolist(module.vpc.public_subnets)
}

output "vpc_private_subnet_ids" {
  description = "A list of IDs of private subnets."
  value       = tolist(module.vpc.private_subnets)
}

output "controller_elb_id" {
  description = "The ID of the Controller ELB."
  value       = module.controller_elb.elb_id
}

output "controller_elb_dns_name" {
  description = "The DNS name of the Controller ELB."
  value       = lower(module.controller_elb.elb_dns_name)
}

output "events_service_elb_id" {
  description = "The ID of the Events Service ELB."
  value       = module.events_service_elb.elb_id
}

output "events_service_elb_dns_name" {
  description = "The DNS name of the Events Service ELB."
  value       = lower(module.events_service_elb.elb_dns_name)
}

output "resource_tags" {
  description = "List of AWS resource tags."
  value       = module.enterprise_console.tags_all
}

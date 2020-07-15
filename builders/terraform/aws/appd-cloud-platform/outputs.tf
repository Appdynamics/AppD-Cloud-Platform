output "ids" {
  description = "List of IDs of instances."
  value       = module.enterprise_console.id
}

output "private_ip" {
  description = "List of private IP addresses assigned to the instances."
  value       = module.enterprise_console.private_ip
}

output "public_dns" {
  description = "List of public DNS names assigned to the instances."
  value       = module.enterprise_console.public_dns
}

output "vpc_security_group_ids" {
  description = "List of VPC security group ids assigned to the instances."
  value       = module.enterprise_console.vpc_security_group_ids
}

output "root_block_device_volume_ids" {
  description = "List of volume IDs of root block devices of instances."
  value       = module.enterprise_console.root_block_device_volume_ids
}

output "ebs_block_device_volume_ids" {
  description = "List of volume IDs of EBS block devices of instances."
  value       = module.enterprise_console.ebs_block_device_volume_ids
}

output "tags" {
  description = "List of tags."
  value       = module.enterprise_console.tags
}

output "placement_group" {
  description = "List of placement group."
  value       = module.enterprise_console.placement_group
}

output "instance_id" {
  description = "EC2 instance ID."
  value       = module.enterprise_console.id[0]
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance."
  value       = module.enterprise_console.public_dns[0]
}

output "credit_specification" {
  description = "Credit specification of EC2 instance (empty list for non-t2 instance types)."
  value       = module.enterprise_console.credit_specification
}

output "aws_region" {
  description = "AWS region."
  value       = var.aws_region
}

output "aws_ec2_ec_hostname_prefix" {
  description = "AWS EC2 Enterprise Console hostname prefix."
  value       = var.aws_ec2_ec_hostname_prefix
}

output "aws_ec2_controller_hostname_prefix" {
  description = "AWS EC2 Controller hostname prefix."
  value       = var.aws_ec2_controller_hostname_prefix
}

output "aws_ec2_es_hostname_prefix" {
  description = "AWS EC2 Events Service hostname prefix."
  value       = var.aws_ec2_es_hostname_prefix
}

output "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  value       = var.aws_ec2_domain
}

output "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  value       = var.aws_ec2_user_name
}

output "aws_ec2_instance_count" {
  description = "Number of AWS EC2 instances to create."
  value       = var.aws_ec2_instance_count
}

output "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  value       = var.aws_ec2_instance_type
}

#output "aws_access_key" {
#  description = "AWS access key ID."
#  value       = var.aws_access_key
#}

#output "aws_secret_key" {
#  description = "AWS secret access key."
#  value       = var.aws_secret_key
#}

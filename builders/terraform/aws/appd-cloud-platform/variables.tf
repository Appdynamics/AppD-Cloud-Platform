variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["us-east-2a", "us-east-2b"]
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_vpc_private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "aws_ec2_enterprise_console_hostname_prefix" {
  description = "AWS EC2 Enterprise Console hostname prefix."
  type        = string
  default     = "enterprise-console-node"
}

variable "aws_ec2_controller_hostname_prefix" {
  description = "AWS EC2 Controller hostname prefix."
  type        = string
  default     = "controller-node"
}

variable "aws_ec2_events_service_hostname_prefix" {
  description = "AWS EC2 Events Service hostname prefix."
  type        = string
  default     = "events-service-node"
}

variable "aws_ec2_eum_server_hostname_prefix" {
  description = "AWS EC2 EUM Server hostname prefix."
  type        = string
  default     = "eum-server-node"
}

variable "aws_ec2_domain" {
  description = "AWS EC2 domain name."
  type        = string
  default     = "localdomain"
}

variable "aws_ec2_user_name" {
  description = "AWS EC2 user name."
  type        = string
  default     = "centos"
}

variable "aws_ec2_source_ami_filter" {
  description = "AWS EC2 source AMI disk image filter."
  type        = string
  default     = "AppD-Cloud-Platform-2072-HA-CentOS78-AMI-*"
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "r5a.large"
# default     = "t2.nano"
}

variable "resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "HA-Terraform"
}

variable "resource_tags" {
  description = "Tag names for AWS resources."
  type = map
  default = {
    "Owner"   = "AppDynamics Cloud Channel Sales Team"
    "Project" = "AppDynamics Cloud Platform"
    "Event"   = "AppD Cloud Platform HA Deployment"
  }
}

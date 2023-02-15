# Variables ----------------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_vpc_cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpc_public_subnets" {
  description = "A list of public subnets inside the VPC."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_vpc_private_subnets" {
  description = "A list of private subnets inside the VPC."
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "aws_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic external to AWS."
  type        = string
  default     = "0.0.0.0/0"
}

variable "cisco_ssh_ingress_cidr_blocks" {
  description = "The ingress CIDR blocks for inbound ssh traffic from Cisco networks."
  type        = string
  default     = "128.107.248.205/32,72.163.220.53/32,209.234.175.138/32,173.38.208.173/32"
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

variable "aws_ec2_ssh_pub_key_name" {
  description = "AWS EC2 SSH public key for instance VMs."
  type        = string
  default     = "AppD-Cloud-Platform"
}

variable "aws_ec2_source_ami_filter" {
  description = "AWS EC2 source AMI disk image filter."
  type        = string
  default     = "AppD-Cloud-Platform-2311-HA-CentOS79-AMI-*"
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "m5a.xlarge"
}

variable "controller_node_count" {
  description = "Number of Controller Nodes to launch."
  type        = number
  default     = 2
}

variable "events_service_node_count" {
  description = "Number of Events Service Nodes to launch."
  type        = number
  default     = 3
}

variable "resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "HA"
}

variable "resource_environment_home_tag" {
  description = "Resource environment home tag."
  type        = string
  default     = "AppD Cloud Platform HA Deployment"
}

variable "resource_owner_tag" {
  description = "Resource owner tag."
  type        = string
  default     = "AppDynamics Cloud Channel Sales Team"
}

variable "resource_event_tag" {
  description = "Resource event tag."
  type        = string
  default     = "AppD Cloud Platform HA Deployment"
}

variable "resource_project_tag" {
  description = "Resource project tag."
  type        = string
  default     = "AppDynamics Cloud Platform"
}

variable "resource_owner_email_tag" {
  description = "Resource owner email tag."
  type        = string
  default     = "ed.barberis@appdynamics.com"
}

variable "resource_department_code_tag" {
  description = "Resource department code tag."
  type        = string
  default     = "020430800"
}

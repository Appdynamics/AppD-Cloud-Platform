variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-2"
}

variable "aws_ec2_ec_hostname_prefix" {
  description = "AWS EC2 Enterprise Console hostname prefix."
  type        = string
  default     = "ec-node"
}

variable "aws_ec2_controller_hostname_prefix" {
  description = "AWS EC2 Controller hostname prefix."
  type        = string
  default     = "controller-node"
}

variable "aws_ec2_es_hostname_prefix" {
  description = "AWS EC2 Events Service hostname prefix."
  type        = string
  default     = "es-node"
}

variable "aws_ec2_eum_hostname_prefix" {
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

variable "aws_ec2_instance_count" {
  description = "Number of AWS EC2 instances to create."
  type        = number
  default     = 1
}

variable "aws_ec2_instance_type" {
  description = "AWS EC2 instance type."
  type        = string
  default     = "r5a.large"
# default     = "t2.nano"
}

variable "lab_user_prefix" {
  description = "Lab user name prefix."
  type        = string
  default     = "HA-Terraform"
}

#variable "aws_access_key" {
#  description = "AWS access key ID."
#  type        = string
#}

#variable "aws_secret_key" {
#  description = "AWS secret access key."
#  type        = string
#}

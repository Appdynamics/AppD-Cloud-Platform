# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.29"
}

# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  version = ">= 2.70"
  region  = var.aws_region
}

provider "local" {
  version = ">= 1.4"
}

provider "null" {
  version = ">= 2.1"
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = "${formatdate("YYYY-MM-DD", timestamp())}"
}

# Data Sources -------------------------------------------------------------------------------------
# data sources to get vpc, subnet, security group and ami details.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "appd_cloud_platform_ha_centos78" {
  most_recent = true
  owners      = ["self"]

  filter {
    name = "name"
    values = [var.aws_ec2_source_ami_filter]
  }
}

# Modules ------------------------------------------------------------------------------------------
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 3.13"

  name        = "SG-${var.resource_name_prefix}-${local.current_date}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id
  tags        = var.resource_tags

  ingress_cidr_blocks               = ["0.0.0.0/0"]
  ingress_rules                     = ["http-80-tcp", "http-8080-tcp", "https-443-tcp", "mysql-tcp", "ssh-tcp"]
  egress_rules                      = ["all-all"]
  ingress_with_self                 = [{rule = "all-all"}]
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 9191
      to_port     = 9191
      protocol    = "tcp"
      description = "AppDynamics Enterprise Console HTTP port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8090
      to_port     = 8090
      protocol    = "tcp"
      description = "AppDynamics Controller HTTP port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 8181
      to_port     = 8181
      protocol    = "tcp"
      description = "AppDynamics Controller HTTPS port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 9080
      to_port     = 9081
      protocol    = "tcp"
      description = "AppDynamics Events Service HTTP ports"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 7001
      to_port     = 7002
      protocol    = "tcp"
      description = "AppDynamics EUM Server HTTP/HTTPS ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 5
}

module "enterprise_console" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 1
  use_num_suffix = false

  name                 = "Enterprise-Console-${var.resource_name_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"
  tags                 = var.resource_tags

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_enterprise_console_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "false"
  }))
}

module "controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 2
  use_num_suffix = true

  name                 = "Controller-${var.resource_name_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"
  tags                 = var.resource_tags

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_controller_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "true"
  }))
}

module "events_service" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 3
  use_num_suffix = true

  name                 = "Events-Service-${var.resource_name_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"
  tags                 = var.resource_tags

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_events_service_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "true"
  }))
}

module "eum_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

 instance_count = 1
  use_num_suffix = false

  name                 = "EUM-Server-${var.resource_name_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"
  tags                 = var.resource_tags

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_eum_server_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "false"
  }))
}

# Resources ----------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_access_role" {
  name               = "EC2-Access-Role-${var.resource_name_prefix}-${local.current_date}"
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")
  tags               = var.resource_tags
}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = "EC2-Access-Policy-${var.resource_name_prefix}-${local.current_date}"
  role   = aws_iam_role.ec2_access_role.id
  policy = file("${path.module}/policies/ec2-access-policy.json")
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2-Instance-Profile-${var.resource_name_prefix}-${local.current_date}"
  role = aws_iam_role.ec2_access_role.name
}

resource "local_file" "private_ip_file" {
    filename = "private-ip-file.txt"
    content  = format("%s\n", join("\n", toset(module.enterprise_console.private_ip), toset(module.controller.private_ip), toset(module.events_service.private_ip), toset(module.eum_server.private_ip)))
    file_permission = "0644"
}

resource "local_file" "public_ip_file" {
    filename = "public-ip-file.txt"
    content  = format("%s\n", join("\n", toset(module.enterprise_console.public_ip), toset(module.controller.public_ip), toset(module.events_service.public_ip), toset(module.eum_server.public_ip)))
    file_permission = "0644"
}

resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = join(",", concat(module.enterprise_console.id, module.controller.id, module.events_service.id, module.eum_server.id))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[enterprise_console]
${join("\n", toset(module.enterprise_console.public_dns))}

[controller]
${join("\n", toset(module.controller.public_dns))}

[events_service]
${join("\n", toset(module.events_service.public_dns))}

[eum_server]
${join("\n", toset(module.eum_server.public_dns))}
EOF
EOD
  }

  # delete the ansible public keys folder.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = "rm -Rf public-keys*"
  }

  # run ansible hello world playbook when the ec2 instances are ready.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = "aws --region ${var.aws_region} ec2 wait instance-status-ok --instance-ids ${join(" ", toset(module.enterprise_console.id), toset(module.controller.id), toset(module.events_service.id), toset(module.eum_server.id))} && ansible-playbook -i aws_hosts.inventory helloworld.yml"
  }
}

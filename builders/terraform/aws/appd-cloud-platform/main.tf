# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.28"
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

  ec_user_data = <<EOF
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_terraform_cloud_init.sh

user_name="${var.aws_ec2_user_name}"
export user_name
aws_ec2_hostname="${var.aws_ec2_ec_hostname_prefix}"
export aws_ec2_hostname
aws_ec2_domain="${var.aws_ec2_domain}"
export aws_ec2_domain
aws_cli_default_region_name="${var.aws_region}"
export aws_cli_default_region_name
use_aws_ec2_num_suffix="false"
export use_aws_ec2_num_suffix

./initialize_al2_terraform_cloud_init.sh
EOF

  controller_user_data = <<EOF
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_terraform_cloud_init.sh

user_name="${var.aws_ec2_user_name}"
export user_name
aws_ec2_hostname="${var.aws_ec2_controller_hostname_prefix}"
export aws_ec2_hostname
aws_ec2_domain="${var.aws_ec2_domain}"
export aws_ec2_domain
aws_cli_default_region_name="${var.aws_region}"
export aws_cli_default_region_name
use_aws_ec2_num_suffix="true"
export use_aws_ec2_num_suffix

./initialize_al2_terraform_cloud_init.sh
EOF

  es_user_data = <<EOF
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_terraform_cloud_init.sh

user_name="${var.aws_ec2_user_name}"
export user_name
aws_ec2_hostname="${var.aws_ec2_es_hostname_prefix}"
export aws_ec2_hostname
aws_ec2_domain="${var.aws_ec2_domain}"
export aws_ec2_domain
aws_cli_default_region_name="${var.aws_region}"
export aws_cli_default_region_name
use_aws_ec2_num_suffix="true"
export use_aws_ec2_num_suffix

./initialize_al2_terraform_cloud_init.sh
EOF

  eum_user_data = <<EOF
#!/bin/sh
cd /opt/appd-cloud-kickstart/provisioners/scripts/aws
chmod 755 ./initialize_al2_terraform_cloud_init.sh

user_name="${var.aws_ec2_user_name}"
export user_name
aws_ec2_hostname="${var.aws_ec2_eum_hostname_prefix}"
export aws_ec2_hostname
aws_ec2_domain="${var.aws_ec2_domain}"
export aws_ec2_domain
aws_cli_default_region_name="${var.aws_region}"
export aws_cli_default_region_name
use_aws_ec2_num_suffix="false"
export use_aws_ec2_num_suffix

./initialize_al2_terraform_cloud_init.sh
EOF
}

# Data Sources -------------------------------------------------------------------------------------
# Data sources to get VPC, subnet, security group and AMI details
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "appd_cloud_platform_ha_centos78" {
  most_recent = true

  owners = ["self"]

  filter {
    name = "name"

    values = [
      "AppD-Cloud-Platform-2066-HA-CentOS78-AMI-*",
    ]
  }
}

data "aws_iam_policy" "ec2_readonly_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "s3_readonly_access_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Resources ----------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_access_role" {
  name = "ec2_access_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}

#resource "aws_iam_role_policy" "ec2_access_policy" {
#  name   = "ec2_access_policy"
#  role   = aws_iam_role.ec2_access_role.id
#  policy = data.aws_iam_policy.ec2_readonly_access_policy.policy
#}

resource "aws_iam_role_policy" "ec2_access_policy" {
  name   = "ec2_access_policy"
  role   = aws_iam_role.ec2_access_role.id
  # policy = data.aws_iam_policy.ec2_readonly_access_policy.policy
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ec2:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "elasticloadbalancing:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudwatch:ListMetrics",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:Describe*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "autoscaling:Describe*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_access_role.name
}

resource "local_file" "private_ip_file" {
    filename = "private-ip-file.txt"
    content  = format("%s\n", join("\n", module.enterprise_console.private_ip))
    file_permission = "0644"
}

resource "local_file" "public_dns_file" {
    filename = "public-dns-file.txt"
    content  = format("%s\n", join("\n", module.enterprise_console.public_dns))
    file_permission = "0644"
}

# Modules ------------------------------------------------------------------------------------------
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 3.12"

  name        = "${var.lab_user_prefix}-SG-${local.current_date}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "http-8080-tcp", "mysql-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
  ingress_with_self   = [{rule = "all-all"}]
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
      from_port   = 9080
      to_port     = 9080
      protocol    = "tcp"
      description = "AppDynamics Events Service HTTP port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  number_of_computed_ingress_with_cidr_blocks = 3
}

module "enterprise_console" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 1
  use_num_suffix = false

  name                 = "EC-${var.lab_user_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.ec_user_data)

  tags = {
    "Owner"   = "Ed Barberis"
    "Project" = "AppDynamics Cloud Platform"
    "Event"   = "AppD Cloud Platform HA Deployment"
  }
}

module "controller" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 2
  use_num_suffix = true

  name                 = "Controller-${var.lab_user_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.controller_user_data)

  tags = {
    "Owner"   = "Ed Barberis"
    "Project" = "AppDynamics Cloud Platform"
    "Event"   = "AppD Cloud Platform HA Deployment"
  }
}

module "events_service" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 3
  use_num_suffix = true

  name                 = "Events-Service-${var.lab_user_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.es_user_data)

  tags = {
    "Owner"   = "Ed Barberis"
    "Project" = "AppDynamics Cloud Platform"
    "Event"   = "AppD Cloud Platform HA Deployment"
  }
}

module "eum_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 2.15"

  instance_count = 1
  use_num_suffix = false

  name                 = "EUM-Server-${var.lab_user_prefix}-${local.current_date}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos78.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = "AppD-Cloud-Platform"

  subnet_id                   = tolist(data.aws_subnet_ids.all.ids)[0]
  // private_ips                 = ["172.31.32.5", "172.31.46.20"]
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(local.eum_user_data)

  tags = {
    "Owner"   = "Ed Barberis"
    "Project" = "AppDynamics Cloud Platform"
    "Event"   = "AppD Cloud Platform HA Deployment"
  }
}

resource "null_resource" "ansible_trigger" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    ec2_instance_ids = join(",", concat(module.enterprise_console.id, module.controller.id, module.events_service.id, module.eum_server.id))
  }

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

  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = "aws ec2 wait instance-status-ok --instance-ids ${join(" ", toset(module.enterprise_console.id), toset(module.controller.id), toset(module.events_service.id), toset(module.eum_server.id))} && ansible-playbook -i aws_hosts.inventory helloworld.yml"
  }
}

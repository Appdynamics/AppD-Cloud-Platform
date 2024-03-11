# Providers ----------------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region
}

# Locals -------------------------------------------------------------------------------------------
locals {
  # format current date for convenience.
  current_date = formatdate("YYYY-MM-DD", timestamp())

  # create range of formatted controller node numbers.
  controller_for_each = toset([ for i in range(1, var.controller_node_count + 1) : format("%02d", i) ])

  # create range of formatted events service node numbers.
  events_service_for_each = toset([ for i in range(1, var.events_service_node_count + 1) : format("%02d", i) ])

  # create vm ssh ingress cidr block list without duplicates.
  vm_ssh_ingress_cidr_blocks = join(",", distinct(tolist([var.aws_ssh_ingress_cidr_blocks, var.cisco_ssh_ingress_cidr_blocks])))

  # define resource tagging here to ensure standardized naming conventions.
  # node tag names for aws resources.
  node_resource_tags = {
    EnvironmentHome = var.resource_environment_home_tag
    Owner           = var.resource_owner_tag
    Event           = var.resource_event_tag
    Project         = var.resource_project_tag
    Date            = local.current_date
  }

  # cisco tag names for aws resources.
  cisco_resource_tags = {
    ResourceOwner         = var.resource_owner_email_tag
    CiscoMailAlias        = var.resource_owner_email_tag
    JIRAProject           = "NA"
    DataClassification    = "Cisco Public"
    JIRACreation          = "NA"
    SecurityReview        = "NA"
    Exception             = "NA"
    Environment           = "NonProd"
    DeploymentEnvironment = "NonProd"
    DataTaxonomy          = "Cisco Operations Data"
    CreatedBy             = data.aws_caller_identity.current.arn
    IntendedPublic        = "True"
    ContainsPII           = "False"
    Service               = "AppDCloudPlatformHADeployment"
    ApplicationName       = var.resource_project_tag
    CostCenter            = var.resource_department_code_tag
  }

  # merge 'node_resource_tags' and 'cisco_resource_tags' into one set.
  resource_tags = merge(local.node_resource_tags, local.cisco_resource_tags)
}

# Data Sources -------------------------------------------------------------------------------------
data "aws_caller_identity" "current" {
}

data "aws_availability_zones" "available" {
}

data "aws_ami" "appd_cloud_platform_ha_centos79" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.aws_ec2_source_ami_filter]
  }
}

# Modules ------------------------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.5"

  name = "VPC-${var.resource_name_prefix}-${local.current_date}"
  cidr = var.aws_vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  public_subnets  = var.aws_vpc_public_subnets
  private_subnets = var.aws_vpc_private_subnets

  enable_nat_gateway         = true
  single_nat_gateway         = true
  enable_dns_hostnames       = true
  manage_default_network_acl = false
  map_public_ip_on_launch    = true

  tags = local.resource_tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = ">= 5.1"

  name        = "SG-${var.resource_name_prefix}-${local.current_date}"
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id
  tags        = local.resource_tags

  ingress_cidr_blocks               = ["0.0.0.0/0"]
  ingress_rules                     = ["http-80-tcp", "http-8080-tcp", "https-443-tcp"]
  egress_rules                      = ["all-all"]
  ingress_with_self                 = [{rule = "all-all"}]
  computed_ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH port"
      cidr_blocks = local.vm_ssh_ingress_cidr_blocks
    },
    {
      from_port   = 9191
      to_port     = 9191
      protocol    = "tcp"
      description = "AppDynamics Enterprise Console HTTP port"
      cidr_blocks = local.vm_ssh_ingress_cidr_blocks
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
  number_of_computed_ingress_with_cidr_blocks = 6
}

module "enterprise_console" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = ">= 5.6"

  name                 = "Enterprise-Console-${var.resource_name_prefix}-${local.current_date}-Node"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = local.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
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
  version = ">= 5.6"

  for_each = local.controller_for_each

  name                 = "Controller-${var.resource_name_prefix}-${local.current_date}-Node-${each.key}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = local.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
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
  version = ">= 5.6"

  for_each = local.events_service_for_each

  name                 = "Events-Service-${var.resource_name_prefix}-${local.current_date}-Node-${each.key}"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = local.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
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
  version = ">= 5.6"

  name                 = "EUM-Server-${var.resource_name_prefix}-${local.current_date}-Node"
  ami                  = data.aws_ami.appd_cloud_platform_ha_centos79.id
  instance_type        = var.aws_ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  key_name             = var.aws_ec2_ssh_pub_key_name
  tags                 = local.resource_tags

  capacity_reservation_specification = {
    capacity_reservation_preference = "none"
#   capacity_reservation_preference = "open"
  }

  subnet_id                   = tolist(module.vpc.public_subnets)[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  user_data_base64 = base64encode(templatefile("${path.module}/templates/user-data-sh.tmpl", {
    aws_ec2_user_name           = var.aws_ec2_user_name,
    aws_ec2_hostname_prefix     = var.aws_ec2_eum_server_hostname_prefix,
    aws_ec2_domain              = var.aws_ec2_domain,
    aws_cli_default_region_name = var.aws_region,
    use_aws_ec2_num_suffix      = "false"
  }))
}

module "controller_elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = ">= 4.0"

  name            = "Controller-ELB-${var.resource_name_prefix}-${local.current_date}"
  subnets         = tolist(module.vpc.public_subnets)
  security_groups = [module.security_group.security_group_id]
  internal        = false
  create_elb      = true

  listener = [
    {
      instance_port     = "8090"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    }
  ]

  health_check = {
    target              = "HTTP:8090/controller/rest/serverstatus"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  # elb attachments.
  number_of_instances = var.controller_node_count
# number_of_instances = length(toset(flatten([for vm in module.controller : vm.id])))
  instances           = toset(flatten([for vm in module.controller : vm.id]))
  tags                = local.resource_tags
}

module "events_service_elb" {
  source  = "terraform-aws-modules/elb/aws"
  version = ">= 4.0"

  name            = "Events-Service-ELB-${var.resource_name_prefix}-${local.current_date}"
  subnets         = tolist(module.vpc.public_subnets)
  security_groups = [module.security_group.security_group_id]
  internal        = false
  create_elb      = true

  listener = [
    {
      instance_port     = "9080"
      instance_protocol = "http"
      lb_port           = "80"
      lb_protocol       = "http"
    }
  ]

  health_check = {
    target              = "HTTP:9081/healthcheck?pretty=true"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
  }

  # elb attachments.
  number_of_instances = var.events_service_node_count
# number_of_instances = length(toset(flatten([for vm in module.events_service : vm.id])))
  instances           = toset(flatten([for vm in module.events_service : vm.id]))
  tags                = local.resource_tags
}

# Resources ----------------------------------------------------------------------------------------
resource "aws_iam_role" "ec2_access_role" {
  name               = "EC2-Access-Role-${var.resource_name_prefix}-${local.current_date}"
  assume_role_policy = file("${path.module}/policies/ec2-assume-role-policy.json")
  tags               = local.resource_tags
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
  filename        = "private-ip-file.txt"
  content         = format("%s\n", join("\n", toset([module.enterprise_console.private_ip]), toset(flatten([for vm in module.controller : vm.private_ip])), toset(flatten([for vm in module.events_service : vm.private_ip])), toset([module.eum_server.private_ip])))
  file_permission = "0644"
}

resource "local_file" "public_ip_file" {
  filename        = "public-ip-file.txt"
  content         = format("%s\n", join("\n", toset([module.enterprise_console.public_ip]), toset(flatten([for vm in module.controller : vm.public_ip])), toset(flatten([for vm in module.events_service : vm.public_ip])), toset([module.eum_server.public_ip])))
  file_permission = "0644"
}

resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any ec2 instance requires re-provisioning.
  triggers = {
    ec2_instance_ids = join(",", concat([module.enterprise_console.id], flatten([for vm in module.controller : vm.id]), flatten([for vm in module.events_service : vm.id]), [module.eum_server.id]))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible aws hosts inventory.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command     = <<EOD
cat <<EOF > aws_hosts.inventory
[enterprise_console]
${join("\n", toset([module.enterprise_console.public_dns]))}

[controller]
${join("\n", toset(flatten([for vm in module.controller : vm.public_dns])))}

[events_service]
${join("\n", toset(flatten([for vm in module.events_service : vm.public_dns])))}

[eum_server]
${join("\n", toset([module.eum_server.public_dns]))}
EOF
EOD
  }

  # generate ansible data file with controller elb dns name.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform/roles/appdynamics.apm-platform-ha/files"
    command     = <<EOD
cat <<EOF > controller_elb_dns_name.txt
${format("http://%s:80", lower(module.controller_elb.elb_dns_name))}
EOF
EOD
  }

  # generate ansible data file with events service elb dns name.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform/roles/appdynamics.apm-platform-ha/files"
    command     = <<EOD
cat <<EOF > events_service_elb_dns_name.txt
${format("http://%s:80", lower(module.events_service_elb.elb_dns_name))}
EOF
EOD
  }

  # delete the ansible public keys folder.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command     = "rm -Rf public-keys*"
  }

  # run ansible hello world playbook when the ec2 instances are ready.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command     = "aws --region ${var.aws_region} ec2 wait instance-status-ok --instance-ids ${join(" ", toset([module.enterprise_console.id]), toset(flatten([for vm in module.controller : vm.id])), toset(flatten([for vm in module.events_service : vm.id])), toset([module.eum_server.id]))} && ansible-playbook -i aws_hosts.inventory roles/appdynamics.apm-platform-ha/tests/helloworld.yml"
  }
}

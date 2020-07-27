# Terraform ----------------------------------------------------------------------------------------
terraform {
  required_version = ">= 0.12.29"
}

# Providers ----------------------------------------------------------------------------------------
provider "google" {
  version = ">= 3.32"

  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

provider "null" {
  version = ">= 2.1"
}

# Locals -------------------------------------------------------------------------------------------
#locals {
#  gcp_vm_index = module.enterprise_console.labels
#}

# Data Sources -------------------------------------------------------------------------------------
#data "google_compute_zones" "available" {
#}

# Resources ----------------------------------------------------------------------------------------

# Modules ------------------------------------------------------------------------------------------
module "instance_template" {
  source  = "terraform-google-modules/vm/google//modules/instance_template"
  version = ">= 3.0.0"

  region               = var.gcp_region
  project_id           = var.gcp_project_id
  service_account      = var.gcp_service_account
  network              = var.gcp_network
# subnetwork           = var.gcp_subnetwork
  source_image_project = var.gcp_project_id
  source_image_family  = var.gcp_source_image_family
  source_image         = var.gcp_source_image
  machine_type         = var.gcp_machine_type
  disk_size_gb         = 128
  metadata      = {
    ssh-keys = "${var.gcp_ssh_username}:${file(var.gcp_ssh_pub_key_path)}"
  }
}

module "enterprise_console" {
  source  = "./modules/compute_instance"

  num_instances  = 1
  use_num_suffix = false

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = var.gcp_network
# subnetwork        = var.gcp_subnetwork
  hostname          = var.gcp_enterprise_console_hostname_prefix
  instance_template = module.instance_template.self_link

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

module "controller" {
  source  = "./modules/compute_instance"

  num_instances  = 2
  use_num_suffix = true

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = var.gcp_network
# subnetwork        = var.gcp_subnetwork
  hostname          = var.gcp_controller_hostname_prefix
  instance_template = module.instance_template.self_link

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

module "events_service" {
  source  = "./modules/compute_instance"

  num_instances  = 3
  use_num_suffix = true

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = var.gcp_network
# subnetwork        = var.gcp_subnetwork
  hostname          = var.gcp_events_service_hostname_prefix
  instance_template = module.instance_template.self_link

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

module "eum_server" {
  source  = "./modules/compute_instance"

  num_instances  = 1
  use_num_suffix = false

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = var.gcp_network
# subnetwork        = var.gcp_subnetwork
  hostname          = var.gcp_eum_server_hostname_prefix
  instance_template = module.instance_template.self_link

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

resource "null_resource" "ansible_trigger" {
  # fire the ansible trigger when any vm instance requires re-provisioning.
  triggers = {
    gcp_instance_ids = join(",", concat(module.enterprise_console.instance_id, module.controller.instance_id, module.events_service.instance_id, module.eum_server.instance_id))
  }

  # execute the following 'local-exec' provisioners each time the trigger is invoked.
  # generate the ansible gcp hosts inventory.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = <<EOD
cat <<EOF > gcp_hosts.inventory
[enterprise_console]
${join("\n", toset(module.enterprise_console.nat_ip))}

[controller]
${join("\n", toset(module.controller.nat_ip))}

[events_service]
${join("\n", toset(module.events_service.nat_ip))}

[eum_server]
${join("\n", toset(module.eum_server.nat_ip))}
EOF
EOD
  }

  # delete the ansible public keys folder.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = "rm -Rf public-keys*"
  }
}

# Providers ----------------------------------------------------------------------------------------
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_zone
}

# Locals -------------------------------------------------------------------------------------------
locals {
  current_date = formatdate("YYYY-MM-DD", timestamp())
}

# Data Sources -------------------------------------------------------------------------------------
data "google_compute_zones" "available" {
}

# Modules ------------------------------------------------------------------------------------------
module "instance_template" {
  source  = "./modules/instance_template"

  region               = var.gcp_region
  project_id           = var.gcp_project_id
  service_account      = var.gcp_service_account
  network              = google_compute_network.vpc.name
  subnetwork           = google_compute_subnetwork.vpc-public-subnet-01.name
  source_image_project = var.gcp_source_image_project
  source_image_family  = var.gcp_source_image_family
  source_image         = var.gcp_source_image
  machine_type         = var.gcp_machine_type
  disk_size_gb         = 128

  metadata = {
    ssh-keys = "${var.gcp_ssh_username}:${file(var.gcp_ssh_pub_key_path)}"
  }

  labels = var.resource_labels
}

module "enterprise_console" {
  source  = "./modules/compute_instance"

  num_instances  = 1
  use_num_suffix = false

  region            = var.gcp_region
  zone              = var.gcp_zone
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.vpc-public-subnet-01.name
  hostname          = var.gcp_enterprise_console_hostname_prefix
  instance_template = module.instance_template.self_link
  labels            = var.resource_labels

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
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.vpc-public-subnet-01.name
  hostname          = var.gcp_controller_hostname_prefix
  instance_template = module.instance_template.self_link
  labels            = var.resource_labels

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
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.vpc-public-subnet-01.name
  hostname          = var.gcp_events_service_hostname_prefix
  instance_template = module.instance_template.self_link
  labels            = var.resource_labels

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
  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.vpc-public-subnet-01.name
  hostname          = var.gcp_eum_server_hostname_prefix
  instance_template = module.instance_template.self_link
  labels            = var.resource_labels

  access_config = [
    {
      nat_ip       = null
      network_tier = var.gcp_network_tier
    },
  ]
}

# Resources ----------------------------------------------------------------------------------------
resource "google_compute_network" "vpc" {
  name                    = "vpc-${var.gcp_resource_name_prefix}-${local.current_date}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpc-public-subnet-01" {
  name          = "subnet-${var.gcp_resource_name_prefix}-${local.current_date}-01"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "vpc-public-subnet-02" {
  name          = "subnet-${var.gcp_resource_name_prefix}-${local.current_date}-02"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.gcp_region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow-icmp" {
  name    = "firewall-rule-allow-icmp-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["${var.gcp_firewall_source_range}"]
# target_tags   = ["allow-icmp"]
}

resource "google_compute_firewall" "allow-internal" {
  name    = "firewall-rule-allow-internal-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.0.1.0/24", "10.0.2.0/24"]
# target_tags   = ["allow-internal"]
}

resource "google_compute_firewall" "allow-ssh" {
  name    = "firewall-rule-allow-ssh-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["22"]
  }

  source_ranges = ["${var.gcp_firewall_source_range}"]
# target_tags   = ["allow-ssh"]
}

resource "google_compute_firewall" "allow-appd" {
  name    = "firewall-rule-allow-appd-${var.gcp_resource_name_prefix}-${local.current_date}"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports = ["80", "443", "3306", "7001-7002", "8080", "8090", "8181", "9080-9081", "9191"]
  }

  source_ranges = ["0.0.0.0/0"]
# target_tags   = ["allow-appd"]
}

# create controller load balancer. -----------------------------------------------------------------
resource "google_compute_global_address" "controller_global_ip" {
  name         = "controller-global-ip-${var.gcp_resource_name_prefix}-${local.current_date}"
  description  = "The global IP address of the Controller load balancer."
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "controller_rule" {
  name       = "controller-rule-port-80-${var.gcp_resource_name_prefix}-${local.current_date}"
  target     = google_compute_target_http_proxy.controller_target.self_link
  ip_address = google_compute_global_address.controller_global_ip.address
  port_range = "80"
}

resource "google_compute_target_http_proxy" "controller_target" {
  name    = "controller-target-http-proxy-${var.gcp_resource_name_prefix}-${local.current_date}"
  url_map = google_compute_url_map.controller_url_map.self_link
}

resource "google_compute_url_map" "controller_url_map" {
  name            = "controller-url-map-${var.gcp_resource_name_prefix}-${local.current_date}"
  default_service = google_compute_backend_service.controller_backend_service.self_link
}

resource "google_compute_instance_group" "controller_group" {
  name      = "controller-instance-group-${var.gcp_resource_name_prefix}-${local.current_date}"
  zone      = var.gcp_zone
  instances = module.controller.instances_self_links

  named_port {
    name = "controller-http"
    port = "8090"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "controller_backend_service" {
  name      = "controller-backend-service-${var.gcp_resource_name_prefix}-${local.current_date}"
  port_name = "controller-http"
  protocol  = "HTTP"

  backend {
    group = google_compute_instance_group.controller_group.id
  }

  health_checks = [google_compute_health_check.controller_health_check.id]
}

resource "google_compute_health_check" "controller_health_check" {
  name   = "controller-health-check-${var.gcp_resource_name_prefix}-${local.current_date}"

  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    request_path = "/controller/rest/serverstatus"
    port = 8090
  }
}

# create events service load balancer. -------------------------------------------------------------
resource "google_compute_global_address" "events_service_global_ip" {
  name         = "events-service-global-ip-${var.gcp_resource_name_prefix}-${local.current_date}"
  description  = "The global IP address of the Events Service load balancer."
  address_type = "EXTERNAL"
}

resource "google_compute_global_forwarding_rule" "events_service_rule" {
  name       = "events-service-rule-port-80-${var.gcp_resource_name_prefix}-${local.current_date}"
  target     = google_compute_target_http_proxy.events_service_target.self_link
  ip_address = google_compute_global_address.events_service_global_ip.address
  port_range = "80"
}

resource "google_compute_target_http_proxy" "events_service_target" {
  name    = "events-service-target-http-proxy-${var.gcp_resource_name_prefix}-${local.current_date}"
  url_map = google_compute_url_map.events_service_url_map.self_link
}

resource "google_compute_url_map" "events_service_url_map" {
  name            = "events-service-url-map-${var.gcp_resource_name_prefix}-${local.current_date}"
  default_service = google_compute_backend_service.events_service_backend_service.self_link
}

resource "google_compute_instance_group" "events_service_group" {
  name      = "events-service-instance-group-${var.gcp_resource_name_prefix}-${local.current_date}"
  zone      = var.gcp_zone
  instances = module.events_service.instances_self_links

  named_port {
    name = "events-service-http"
    port = "9080"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_backend_service" "events_service_backend_service" {
  name      = "events-service-backend-service-${var.gcp_resource_name_prefix}-${local.current_date}"
  port_name = "events-service-http"
  protocol  = "HTTP"

  backend {
    group = google_compute_instance_group.events_service_group.id
  }

  health_checks = [google_compute_health_check.events_service_health_check.id]
}

resource "google_compute_health_check" "events_service_health_check" {
  name   = "events-service-health-check-${var.gcp_resource_name_prefix}-${local.current_date}"

  check_interval_sec  = 30
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout_sec         = 5

  http_health_check {
    request_path = "/"
    port = 9080
  }
}

# create ansible trigger to generate inventory and helper files. -----------------------------------
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

  # generate ansible data file with controller elb dns name.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform/roles/appdynamics.apm-platform-ha/files"
    command     = <<EOD
cat <<EOF > controller_elb_dns_name.txt
${format("http://%s:80", google_compute_global_address.controller_global_ip.address)}
EOF
EOD
  }

  # generate ansible data file with events service elb dns name.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform/roles/appdynamics.apm-platform-ha/files"
    command     = <<EOD
cat <<EOF > events_service_elb_dns_name.txt
${format("http://%s:80", google_compute_global_address.events_service_global_ip.address)}
EOF
EOD
  }

  # delete the ansible public keys folder.
  provisioner "local-exec" {
    working_dir = "../../../../provisioners/ansible/appd-cloud-platform"
    command = "rm -Rf public-keys*"
  }
}

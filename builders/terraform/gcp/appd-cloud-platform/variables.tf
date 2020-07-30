variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
  default     = "appd-cloud-kickstart"
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone."
  type        = string
  default     = "us-central1-a"
}

variable "gcp_network" {
  description = "The network selflink to host the compute instances in"
  type        = string
  default     = "default"
}

#variable "gcp_subnetwork" {
#  description = "The subnetwork selflink to host the compute instances in"
#}

variable "gcp_ec_nat_ip" {
  description = "Public ip address for Enterprise Console instance."
  default     = null
}

variable "gcp_controller_nat_ip" {
  description = "Public ip address for Controller instance."
  default     = null
}

variable "gcp_es_nat_ip" {
  description = "Public ip address for Events Service instance."
  default     = null
}

variable "gcp_eum_server_nat_ip" {
  description = "Public ip address for EUM Server instance."
  default     = null
}

variable "gcp_network_tier" {
  description = "Network network_tier"
  default     = "STANDARD"
}

variable "gcp_enterprise_console_hostname_prefix" {
  description = "GCP Enterprise Console hostname prefix."
  type        = string
  default     = "enterprise-console-node"
}

variable "gcp_controller_hostname_prefix" {
  description = "GCP Controller hostname prefix."
  type        = string
  default     = "controller-node"
}

variable "gcp_events_service_hostname_prefix" {
  description = "GCP Events Service hostname prefix."
  type        = string
  default     = "events-service-node"
}

variable "gcp_eum_server_hostname_prefix" {
  description = "GCP EUM Server hostname prefix."
  type        = string
  default     = "eum-server-node"
}

variable "gcp_ssh_username" {
  description = "GCP user name."
  type        = string
  default     = "centos"
}

variable "gcp_source_image_family" {
  description = "The source image family."
  type        = string
  default     = "appd-cloud-platform-ha-centos78-images"
# default     = "centos-7"
}

variable "gcp_source_image" {
  description = "The source disk image."
  type        = string
  default     = "appd-cloud-platform-2072-ha-centos78-2020-07-27"
# default     = "centos-7-v20200700"
}

variable "gcp_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = true
}

variable "gcp_machine_type" {
  description = "Machine type to create."
  type        = string
  default     = "e2-standard-4"
# default     = "n1-standard-1"
}

variable "gcp_service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type = object({
    email  = string,
    scopes = set(string)
  })
  default = {
    email = "devops@appd-cloud-kickstart.iam.gserviceaccount.com",
    scopes = ["cloud-platform"]
  }
}

variable "gcp_ssh_pub_key_path" {
  default     = "../../../../shared/keys/AppD-Cloud-Platform.pub"
}

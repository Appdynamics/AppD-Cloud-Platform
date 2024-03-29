# Variables ----------------------------------------------------------------------------------------
variable "gcp_project_id" {
  description = "GCP Project ID."
  type        = string
  default     = "gcp-appdcloudplatfo-nprd-68190"
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

variable "gcp_firewall_source_range" {
  description = "The source range for inbound ssh traffic external to GCP."
  type        = list
  default     = ["0.0.0.0/0"]
}

variable "cisco_firewall_source_range" {
  description = "The source range for inbound ssh traffic from Cisco networks."
  type        = list
  default     = ["128.107.241.0/24", "128.107.248.0/24", "72.163.220.53/32", "209.234.175.138/32", "173.38.208.173/32"]
}

variable "gcp_network_tier" {
  description = "Network network_tier"
  type        = string
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

variable "gcp_source_image_project" {
  description = "The source image project."
  type        = string
  default     = "gcp-appdcloudplatfo-nprd-68190"
# default     = "centos-cloud"
}

variable "gcp_source_image_family" {
  description = "The source image family."
  type        = string
  default     = "appd-cloud-platform-ha-centos79-images"
# default     = "centos-7"
}

variable "gcp_use_num_suffix" {
  description = "Always append numerical suffix to instance name, even if instance_count is 1"
  type        = bool
  default     = true
}

variable "gcp_machine_type" {
  description = "GCE machine type to create."
  type        = string
  default     = "e2-standard-4"
}

variable "gcp_resource_name_prefix" {
  description = "Resource name prefix."
  type        = string
  default     = "ha"
}

variable "resource_environment_home_label" {
  description = "Resource environment home label."
  type        = string
  default     = "appd-cloud-platform-ha-deployment"
}

variable "resource_owner_label" {
  description = "Resource owner label."
  type        = string
  default     = "appdynamics-cloud-channel-sales-team"
}

variable "resource_event_label" {
  description = "Resource event label."
  type        = string
  default     = "appd-cloud-platform-ha-deployment"
}

variable "resource_project_label" {
  description = "Resource project label."
  type        = string
  default     = "appdynamics-cloud-platform"
}

variable "resource_owner_email_label" {
  description = "Resource owner email label."
  type        = string
  default     = "ebarberi-at-cisco-com"
}

variable "resource_department_code_label" {
  description = "Resource department code label."
  type        = string
  default     = "020430801"
}

variable "gcp_service_account" {
  description = "Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account."
  type        = object({
    email  = string,
    scopes = set(string)
  })
  default     = {
    email  = "devops@gcp-appdcloudplatfo-nprd-68190.iam.gserviceaccount.com",
    scopes = ["cloud-platform"]
  }
}

variable "gcp_ssh_pub_key_path" {
  default = "../../../../shared/keys/AppD-Cloud-Platform.pub"
}

output "gcp_enterprise_console_instances_self_links" {
  description = "List of self-links for Enterprise Console compute instance"
  value       = module.enterprise_console.instances_self_links
}

output "gcp_controller_instances_self_links" {
  description = "List of self-links for Controller compute instances"
  value       = module.controller.instances_self_links
}

output "gcp_events_service_instances_self_links" {
  description = "List of self-links for Events Service compute instances"
  value       = module.events_service.instances_self_links
}

output "gcp_eum_server_instances_self_links" {
  description = "List of self-links for EUM Server compute instance"
  value       = module.eum_server.instances_self_links
}

output "gcp_enterprise_console_available_zones" {
  description = "List of available zones in region"
  value       = module.enterprise_console.available_zones
}

output "gcp_instance_template_self_link" {
  value       = module.instance_template.self_link
}

output "gcp_instance_template_name" {
  value       = module.instance_template.name
}

output "gcp_instance_template_tags" {
  value       = module.instance_template.tags
}

output "gcp_enterprise_console_id" {
  description = "An identifier for the Enterprise Console resource."
  value       = module.enterprise_console.id
}

output "gcp_controller_id" {
  description = "An identifier for the Controller resource."
  value       = module.controller.id
}

output "gcp_events_service_id" {
  description = "An identifier for the Events Service resource."
  value       = module.events_service.id
}

output "gcp_eum_server_id" {
  description = "An identifier for the EUM Server resource."
  value       = module.eum_server.id
}

output "gcp_enterprise_console_instance_id" {
  description = "The server-assigned unique identifier of this Enterprise Console instance."
  value       = module.enterprise_console.instance_id
}

output "gcp_controller_instance_id" {
  description = "The server-assigned unique identifier of this Controller instance."
  value       = module.controller.instance_id
}

output "gcp_events_service_instance_id" {
  description = "The server-assigned unique identifier of this Events Service instance."
  value       = module.events_service.instance_id
}

output "gcp_eum_server_instance_id" {
  description = "The server-assigned unique identifier of this EUM Server instance."
  value       = module.eum_server.instance_id
}

output "gcp_enterprise_console_network_ip" {
  description = "The private IP address assigned to the Enterprise Console instance."
  value       = module.enterprise_console.network_ip
}

output "gcp_controller_network_ip" {
  description = "The private IP address assigned to the Controller instance."
  value       = module.controller.network_ip
}

output "gcp_events_service_network_ip" {
  description = "The private IP address assigned to the Events Service instance."
  value       = module.events_service.network_ip
}

output "gcp_eum_server_network_ip" {
  description = "The private IP address assigned to the EUM Server instance."
  value       = module.eum_server.network_ip
}

output "gcp_enterprise_console_nat_ip" {
  description = "The external IP address assigned to the Enterprise Console instance."
  value       = module.enterprise_console.nat_ip
}

output "gcp_controller_nat_ip" {
  description = "The external IP address assigned to the Controller instance."
  value       = module.controller.nat_ip
}

output "gcp_events_service_nat_ip" {
  description = "The external IP address assigned to the Events Service instance."
  value       = module.events_service.nat_ip
}

output "gcp_eum_server_nat_ip" {
  description = "The external IP address assigned to the EUM Server instance."
  value       = module.eum_server.nat_ip
}

output "gcp_controller_global_ip_address" {
  description = "The global IP address of the Controller load balancer."
  value       = google_compute_global_address.controller_global_ip.address
}

output "gcp_events_service_global_ip_address" {
  description = "The global IP address of the Events Service load balancer."
  value       = google_compute_global_address.events_service_global_ip.address
}

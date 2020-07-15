output "gcp_ec_instances_self_links" {
  description = "List of self-links for Enterprise Console compute instances"
  value       = module.enterprise_console.instances_self_links
}

output "gcp_controller_instances_self_links" {
  description = "List of self-links for Controller compute instances"
  value       = module.controller.instances_self_links
}

output "gcp_es_instances_self_links" {
  description = "List of self-links for Events Service compute instances"
  value       = module.events_service.instances_self_links
}

output "gcp_ec_available_zones" {
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

output "gcp_ec_id" {
  description = "An identifier for the Enterprise Console resource."
  value       = module.enterprise_console.id
}

output "gcp_controller_id" {
  description = "An identifier for the Controller resource."
  value       = module.controller.id
}

output "gcp_es_id" {
  description = "An identifier for the Events Service resource."
  value       = module.events_service.id
}

output "gcp_ec_instance_id" {
  description = "The server-assigned unique identifier of this Enterprise Console instance."
  value       = module.enterprise_console.instance_id
}

output "gcp_controller_instance_id" {
  description = "The server-assigned unique identifier of this Controller instance."
  value       = module.controller.instance_id
}

output "gcp_es_instance_id" {
  description = "The server-assigned unique identifier of this Events Service instance."
  value       = module.events_service.instance_id
}

output "gcp_ec_network_ip" {
  description = "The private IP address assigned to the Enterprise Console instance."
  value       = module.enterprise_console.network_ip
}

output "gcp_controller_network_ip" {
  description = "The private IP address assigned to the Controller instance."
  value       = module.controller.network_ip
}

output "gcp_es_network_ip" {
  description = "The private IP address assigned to the Events Service instance."
  value       = module.events_service.network_ip
}

output "gcp_ec_nat_ip" {
  description = "The external IP address assigned to the Enterprise Console instance."
  value       = module.enterprise_console.nat_ip
}

output "gcp_controller_nat_ip" {
  description = "The external IP address assigned to the Controller instance."
  value       = module.controller.nat_ip
}

output "gcp_es_nat_ip" {
  description = "The external IP address assigned to the Events Service instance."
  value       = module.events_service.nat_ip
}

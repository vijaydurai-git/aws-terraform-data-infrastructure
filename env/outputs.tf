# Output from VPC module
output "vpc_id_out" {
  description = "VPC ID from VPC module"
  value       = module.vpc_module.vpc_id_out
}

# Output from SG module
output "sg_id_out" {
  description = "Security Group ID from SG module"
  value       = module.sg_module.sg_id_out
}

# Output from compute module
output "instance_public_ip_out" {
  description = "Public IP of EC2 instance from compute module"
  value       = module.compute_module.instance_public_ip_out
}

output "instance_id_out" {
  description = "EC2 instance ID"
  value       = module.compute_module.instance_id_out
}


# # Output content of DNS entry file
# output "dns_entry_content_out" {
#   description = "Contents of DNS entry script"
#   value       = local.dns_entry_content
# }

output "instance_public_ip_out" {
  value = var.external_access_in ? aws_instance.public_instance[0].public_ip : ""
}

output "instance_id_out" {
  value = var.external_access_in ? aws_instance.public_instance[0].id : aws_instance.private_instance[0].id
}
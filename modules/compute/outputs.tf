output "instance_public_ip_out" {

  value = aws_instance.instance.public_ip

}


output "instance_id_out" {

  value = aws_instance.instance.id

}
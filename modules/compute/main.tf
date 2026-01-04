# Public Instance
resource "aws_instance" "public_instance" {
  count                       = var.external_access_in ? 1 : 0
  ami                         = var.ami_id_in
  subnet_id                   = var.public_subnet_id_in
  instance_type               = var.instance_type_in
  key_name                    = var.instance_key_name_in
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id_in]
  iam_instance_profile        = "admin"

  root_block_device {
    volume_size           = var.instance_root_volume_size_in
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.project_tag_in}-root-volume"
    }
  }

  provisioner "file" {
    content     = var.dns_entry_content_in
    destination = "dns_entry.sh"
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/aws_cli.sh"
    destination = "aws_cli.sh"
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/crontab-e.sh"
    destination = "crontab-e.sh"
  }

  provisioner "local-exec" {
    command = "echo Welcome_$(date +'%Y%m%d_%H%M%S')"
  }

  connection {
    type        = "ssh"
    user        = var.server_user_in
    private_key = file("/home/e1087/.jkey.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.project_tag_in}",
      "bash aws_cli.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file("/home/e1087/.jkey.pem")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "${var.project_tag_in}"
  }
}

# Private Instance
resource "aws_instance" "private_instance" {
  count                       = !var.external_access_in ? 1 : 0
  ami                         = var.ami_id_in
  subnet_id                   = var.public_subnet_id_in
  instance_type               = var.instance_type_in
  key_name                    = var.instance_key_name_in
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.sg_id_in]
  iam_instance_profile        = "admin"

  root_block_device {
    volume_size           = var.instance_root_volume_size_in
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.project_tag_in}-root-volume"
    }
  }

  provisioner "local-exec" {
    command = "echo Welcome_Private_$(date +'%Y%m%d_%H%M%S')"
  }

  tags = {
    Name = "${var.project_tag_in}"
  }
}

resource "null_resource" "dns_re-entry" {
  count = (var.confirm_dns_update_in == "yes" && var.external_access_in) ? 1 : 0

  triggers = {
    id = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "bash dns_entry.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file("/home/e1087/.jkey.pem")
      host        = aws_instance.public_instance[0].public_ip
    }
  }
}

# Fetch the ENI and set the tag for it
resource "aws_ec2_tag" "eni_tag" {
  resource_id = var.external_access_in ? aws_instance.public_instance[0].primary_network_interface_id : aws_instance.private_instance[0].primary_network_interface_id
  key         = "Name"
  value       = "${var.project_tag_in}-eni"
}

resource "aws_instance" "public_instance" {
  count                       = var.external_access_in ? 1 : 0
  ami                         = var.ami_id_in
  subnet_id                   = var.public_subnet_id_in
  instance_type               = var.instance_type_in
  key_name                    = var.instance_key_name_in
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.sg_id_in]
  iam_instance_profile        = var.iam_instance_profile_in

  root_block_device {
    volume_size           = var.instance_root_volume_size_in
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.project_tag_in}-root-volume"
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/dns_update.sh"
    destination = "dns_update.sh"
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file(var.ssh_private_key_path_in)
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/aws_cli.sh"
    destination = "aws_cli.sh"
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file(var.ssh_private_key_path_in)
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/crontab-e.sh"
    destination = "crontab-e.sh"
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file(var.ssh_private_key_path_in)
      host        = self.public_ip
    }
  }

  provisioner "local-exec" {
    command = "echo 'Public Instance: ${self.tags.Name} (${self.public_ip}) created at $(date)' >> instance_details.txt"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.project_tag_in}",
      "bash aws_cli.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file(var.ssh_private_key_path_in)
      host        = self.public_ip
    }
  }

  tags = {
    Name = "${var.project_tag_in}"
  }
}

resource "aws_instance" "private_instance" {
  count                       = !var.external_access_in ? 1 : 0
  ami                         = var.ami_id_in
  subnet_id                   = var.private_subnet_id_in
  instance_type               = var.instance_type_in
  key_name                    = var.instance_key_name_in
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.sg_id_in]
  iam_instance_profile        = var.iam_instance_profile_in

  user_data = templatefile("${path.module}/../../scripts/user_data.tftpl", {
    ssh_users = var.ssh_users_in
  })

  root_block_device {
    volume_size           = var.instance_root_volume_size_in
    volume_type           = "gp3"
    delete_on_termination = true
    tags = {
      Name = "${var.project_tag_in}-root-volume"
    }
  }

  provisioner "local-exec" {
    command = "echo 'Private Instance: ${self.tags.Name} (${self.private_ip}) created at $(date)' >> instance_details.txt"
  }

  tags = {
    Name = "${var.project_tag_in}"
  }
}

resource "aws_ec2_tag" "eni_tag" {
  resource_id = var.external_access_in ? aws_instance.public_instance[0].primary_network_interface_id : aws_instance.private_instance[0].primary_network_interface_id
  key         = "Name"
  value       = "${var.project_tag_in}-eni"
}

resource "null_resource" "user_sync" {
  count = var.external_access_in ? 1 : 0

  triggers = {
    users       = jsonencode(var.ssh_users_in)
    instance_id = aws_instance.public_instance[0].id
  }

  connection {
    type        = "ssh"
    user        = var.server_user_in
    private_key = file(var.ssh_private_key_path_in)
    host        = aws_instance.public_instance[0].public_ip
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/add_user.sh"
    destination = "add_user.sh"
  }

  provisioner "file" {
    content     = <<-EOT
      #!/bin/bash
      # Sync Users Script

      # 1. Define Valid Users
      VALID_USERS_LIST="${join(" ", keys(var.ssh_users_in))}"

      # 2. Add/Update Users
      %{for user, key in var.ssh_users_in~}
      bash add_user.sh "${user}" "${key}"
      %{endfor~}

      # 3. Remove Invalid Users (only triggers if group exists)
      if getent group tf-users > /dev/null; then
          EXISTING=$(getent group tf-users | cut -d: -f4 | tr ',' ' ')
          for USER in $EXISTING; do
              # Check if USER is in VALID_USERS_LIST
              IS_VALID=false
              for VALID in $VALID_USERS_LIST; do
                  if [ "$USER" == "$VALID" ]; then
                      IS_VALID=true
                      break
                  fi
              done

              if [ "$IS_VALID" == "false" ]; then
                  echo "User $USER is not in the configuration, but removal is disabled. SKIPPING DELETION."
                  # sudo userdel -r "$USER"
              fi
          done
      fi
    EOT
    destination = "user_sync.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash user_sync.sh"
    ]
  }
}

resource "null_resource" "package_installation" {
  count = length(var.packages_to_install_in) > 0 ? 1 : 0

  triggers = {
    instance_id = var.external_access_in ? aws_instance.public_instance[0].id : aws_instance.private_instance[0].id
    packages    = join(",", var.packages_to_install_in)
  }

  connection {
    type        = "ssh"
    user        = var.server_user_in
    private_key = file(var.ssh_private_key_path_in)
    host        = var.external_access_in ? aws_instance.public_instance[0].public_ip : aws_instance.private_instance[0].private_ip
  }

  provisioner "file" {
    source      = "${path.module}/../../scripts/install_packages.sh"
    destination = "install_packages.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x install_packages.sh",
      "bash install_packages.sh ${join(" ", var.packages_to_install_in)}"
    ]
  }

  provisioner "local-exec" {
    command = "echo 'Package Installation SUCCESSFUL for instance ${self.triggers.instance_id}: ${join(" ", var.packages_to_install_in)}' >> instance_details.txt"
  }

  depends_on = [null_resource.user_sync]
}

resource "null_resource" "dns_re-entry" {
  count = (var.run_dns_update_file_in == "yes" && var.external_access_in) ? 1 : 0

  triggers = {
    id = timestamp()
  }

  provisioner "remote-exec" {
    inline = [
      "bash dns_update.sh"
    ]
    connection {
      type        = "ssh"
      user        = var.server_user_in
      private_key = file(var.ssh_private_key_path_in)
      host        = aws_instance.public_instance[0].public_ip
    }
  }
}
resource "null_resource" "backup_home" {
  count = var.external_access_in ? 1 : 0

  triggers = {
    user             = var.server_user_in
    private_key_path = var.ssh_private_key_path_in
    host             = aws_instance.public_instance[0].public_ip
    instance_name    = aws_instance.public_instance[0].tags["Name"]
    script_version   = "v2"
    backup_bucket    = var.aws_backup_bucket_name_in
    backup_user_name = var.backup_user_in
  }

  connection {
    type        = "ssh"
    user        = self.triggers.user
    private_key = file(self.triggers.private_key_path)
    host        = self.triggers.host
    timeout     = "1m"
  }

  provisioner "remote-exec" {
    when       = destroy
    on_failure = continue
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)",
      "BACKUP_USER=${self.triggers.backup_user_name}",
      "[ -z \"$BACKUP_USER\" ] && echo 'Backup user not defined, skipping backup.' && exit 0",
      "BACKUP_NAME=aws-ec2-backup-user-$BACKUP_USER-hostname-${self.triggers.instance_name}-$TIMESTAMP.zip",
      "echo 'Starting backup for $BACKUP_USER user...'",
      "sudo zip -r /tmp/$BACKUP_NAME /home/$BACKUP_USER",
      "aws s3 ls s3://${self.triggers.backup_bucket} || aws s3 mb s3://${self.triggers.backup_bucket}",
      "aws s3 cp /tmp/$BACKUP_NAME s3://${self.triggers.backup_bucket}/$BACKUP_NAME",
      "echo 'Backup completed successfully to s3://${self.triggers.backup_bucket}/$BACKUP_NAME'"
    ]
  }

  depends_on = [null_resource.user_sync]
}

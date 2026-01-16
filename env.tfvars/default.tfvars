current_project_tag       = "..."
exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"
allowed_ports             = [22, 80, 443]
external_access           = true
run_dns_update_file       = "no"
instance_type             = "..."
instance_key_name         = "jkey"
enter_ami_name            = "ubuntu"
instance_root_volume_size = "20"
server_user               = "ubuntu"
ssh_private_key_path      = "/home/e1087/devops/pemKeys/jkey.pem"
packages_to_install       = ["docker", "zip"]
aws_backup_bucket_name    = ""
backup_user               = ""

ssh_users = {
  # "username" = "ssh-rsa public_key"
}
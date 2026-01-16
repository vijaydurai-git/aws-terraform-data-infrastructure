variable "current_project_tag" {
  description = "Note: The current project tag"
}

variable "exist_vpc_name" {}

variable "exist_public_subnet_name" {}

variable "exist_private_subnet_name" {}

variable "allowed_ports" {
  description = "List of ports to allow"
  type        = list(number)
}

variable "external_access" {
  description = "Set to true for public instances (external access), false for private instances. IMPORTANT: For private instances (false), ensure a NAT Gateway is active and running (managed separately). Refer to https://github.com/git-vijaydurai/aws-terraform-only-vpc.git for VPC/NAT configuration."
  type        = bool
  default     = true
}

variable "instance_type" {}

variable "instance_key_name" {}

variable "enter_ami_name" {
  description = "Enter the username (e.g., 'ubuntu' or 'ec2-user'). The appropriate image will be selected based on your input."
}

variable "instance_root_volume_size" {}

variable "ec2_ami_ids" {
  default = {
    ubuntu22 = "ami-0d9a665f802ae6227" # Ubuntu 22.04 LTS in us-east-2 (Ohio)
    ubuntu24 = "ami-0cb91c7de36eed2cb" # Ubuntu 24.04 LTS in us-east-2 (Ohio)
    ec2-user = "ami-0fc82f4dabc05670b"
    ansible  = "ami-091b900d9ac24daeb" # Base image is ubuntu 22.04 LTS in us-east-2 (Ohio)
  }
}

variable "t2_nano_instance_type" {
  default = "t2.nano"
}
variable "t2_micro_instance_type" {
  default = "t2.micro"
}
variable "t3_micro_instance_type" {
  default = "t3.micro"
}
variable "t3_small_instance_type" {
  default = "t3.small"
}

variable "server_user" {}

variable "ssh_users" {
  description = "Map of username to public SSH key"
  type        = map(string)
  default     = {}
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
}

variable "run_dns_update_file" {
  description = "Enter 'yes' to run DNS update. Note: This only runs if external_access is also true."
  default     = "no"
}

variable "packages_to_install" {
  description = "List of packages to install on the instance"
  type        = list(string)
  default     = []
}

variable "aws_backup_bucket_name" {
  description = "S3 bucket name for backups"
  type        = string
}

variable "backup_user" {
  description = "System user to backup (folder /home/user)"
  type        = string
}



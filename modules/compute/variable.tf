variable "project_tag_in" {}

variable "vpc_id_in" {
  default = ""
}
variable "public_subnet_id_in" {}
variable "private_subnet_id_in" {}
variable "sg_id_in" {}

variable "ami_id_in" {}
variable "instance_type_in" {}
variable "instance_key_name_in" {}
variable "associate_public_ip_address" {
  default = "true"
}
variable "external_access_in" {}
variable "instance_root_volume_size_in" {}
variable "iam_instance_profile_in" {}

variable "server_user_in" {}
variable "ssh_users_in" {
  type    = map(string)
  default = {}
}
variable "ssh_private_key_path_in" {}

variable "packages_to_install_in" {
  type    = list(string)
  default = []
}
variable "run_dns_update_file_in" {}

variable "aws_backup_bucket_name_in" {}
variable "backup_user_in" {}



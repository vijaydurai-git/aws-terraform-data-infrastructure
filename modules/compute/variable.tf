variable "ami_id_in" {}
variable "instance_type_in" {}
variable "public_subnet_id_in" {}
variable "private_subnet_id_in" {}
variable "sg_id_in" {}
variable "project_tag_in" {}
variable "confirm_dns_update_in" {}
variable "server_user_in" {}
variable "instance_key_name_in" {}
variable "dns_entry_content_in" {
  type = string
}
variable "associate_public_ip_address" {
  default = "true"
}


variable "instance_root_volume_size_in" {}
variable "external_access_in" {}
variable "ssh_users_in" {
  type    = map(string)
  default = {}
}

variable "iam_instance_profile_in" {}

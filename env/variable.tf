#Enter Project Name


variable "current_project_tag" {

  description = "Note: The current project tag"
}

variable "confirm_dns_update" {
  description = "Enter 'yes' or 'no' to indicate whether to run the DNS update."
  default     = "no"
}

variable "enter_ami_name" {
  description = "Enter the username (e.g., 'ubuntu' or 'ec2-user'). The appropriate image will be selected based on your input."
}

variable "server_user" {

}
variable "exist_vpc_name" {
}

variable "exist_public_subnet_name" {
}

variable "exist_private_subnet_name" {

}


#To avoid manual changing AMI entries, I have used a map-type variable

variable "ec2_ami_ids" {

  default = {
    ubuntu22 = "ami-0d9a665f802ae6227" # Ubuntu 22.04 LTS in us-east-2 (Ohio)
    ubuntu24 = "ami-0cb91c7de36eed2cb" # Ubuntu 24.04 LTS in us-east-2 (Ohio)
    ec2-user = "ami-0fc82f4dabc05670b"
    ansible  = "ami-091b900d9ac24daeb" # Base image is ubuntu 22.04 LTS in us-east-2 (Ohio)
  }
}



variable "instance_type" {

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

variable "instance_root_volume_size" {

}

variable "allowed_ports" {
  description = "List of ports to allow"
  type        = list(number)
}

variable "instance_key_name" {

}


variable "external_access" {
  description = "Set to true for public instances (external access), false for private instances."
  type        = bool
  default     = true
}

variable "ssh_users" {
  description = "Map of username to public SSH key"
  type        = map(string)
  default     = {}
}

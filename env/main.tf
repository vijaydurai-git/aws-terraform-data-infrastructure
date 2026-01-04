data "local_file" "dns_entry" {
  filename = "${path.module}/../scripts/dns_entry.sh"
}

locals {
  dns_entry_content = data.local_file.dns_entry.content
}


locals {
  current_project_tag = var.current_project_tag
}

module "vpc_module" {

  source                       = "../modules/vpc"
  exist_vpc_name_in            = var.exist_vpc_name
  exist_public_subnet_name_in  = var.exist_public_subnet_name
  exist_private_subnet_name_in = var.exist_private_subnet_name

}


module "sg_module" {

  source           = "../modules/sg"
  vpc_id_in        = module.vpc_module.vpc_id_out
  project_tag_in   = local.current_project_tag
  allowed_ports_in = var.allowed_ports
}
module "compute_module" {

  source                       = "../modules/compute"
  public_subnet_id_in          = module.vpc_module.public_subnet_id_out
  sg_id_in                     = module.sg_module.sg_id_out
  project_tag_in               = local.current_project_tag
  instance_type_in             = var.instance_type
  dns_entry_content_in         = local.dns_entry_content
  confirm_dns_update_in        = var.confirm_dns_update
  ami_id_in                    = var.ec2_ami_ids["${var.enter_ami_name}"]
  server_user_in               = var.server_user
  instance_root_volume_size_in = var.instance_root_volume_size
  instance_key_name_in         = var.instance_key_name
  external_access_in           = var.external_access
}
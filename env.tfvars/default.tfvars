exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"
current_project_tag       = "..."
instance_type             = "..."
enter_ami_name            = "ubuntu"
server_user               = "ubuntu"
instance_root_volume_size = "20"
allowed_ports             = [22, 80, 443]
instance_key_name         = "jkey"
external_access           = true
confirm_dns_update        = "no"


# terraform workspace list
# terraform workspace show
# terraform workspace new <new workspace name>
# terraform apply   --auto-approve -var-file="<exact var file>"   # or run shell file
# terraform destroy --auto-approve -var-file="<exact var file>"   # or run shell file

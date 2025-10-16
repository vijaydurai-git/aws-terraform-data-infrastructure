exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"
current_project_tag       = "ansible"
server_user               = "ubuntu"
instance_type             = "t3.small"
confirm_dns_update        = "yes"
enter_ami_name            = "ansible"
instance_root_volume_size = "20"
allowed_ports             = [22, 80, 443, 9100, 9000]
instance_key_name         = "jkey"

#terraform workspace list 
#terraform workspace show
#terraform workspace new <new workspace name>
#terraform apply --auto-approve -var-file="--exact var file" or run shell file
#terraform destroy --auto-approve -var-file="--exact var file" or run shell file
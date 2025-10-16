exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"
current_project_tag       = "sonarqube"
server_user               = "ubuntu"
instance_type             = "m7i-flex.large"
confirm_dns_update        = "no"
enter_ami_name            = "ubuntu22"
instance_root_volume_size = "50"
allowed_ports             = [22, 80, 443, 9000, 9001]
instance_key_name         = "jkey"

#terraform workspace list 
#terraform workspace show
#terraform workspace new <new workspace name>
#terraform apply --auto-approve -var-file="--exact var file" or run shell file
#terraform destroy --auto-approve -var-file="--exact var file" or run shell file
# 🧩 Terraform AWS Infrastructure Automation

This repository provisions AWS infrastructure (VPC, Security Groups, EC2 instances, etc.) using **Terraform** and modular design.

It supports multiple **workspaces** (e.g., `dev`, `staging`, `prod`) and loads environment-specific variables dynamically using `.tfvars` files.

---

## 📁 Project Structure

```
├── env/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform-apply.sh
│   ├── terraform-destroy.sh
│   └── variable.tf
│
├── env.tfvars/
│   ├── ansible.tfvars
│   ├── default.tfvars
│   ├── jfrog.tfvars
│   ├── prod.tfvars
│   ├── sonarqube.tfvars
│   └── staging.tfvars
│
├── modules/
│   ├── compute/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── sg/
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   └── vpc/
│       ├── main.tf
│       ├── outputs.tf
│       └── variable.tf
│
├── scripts/
│   ├── aws_cli.sh
│   ├── crontab-e.sh
│   └── dns_entry.sh
│
└── README.md
```

---

## ⚙️ How It Works

Each environment (workspace) has its own `.tfvars` file under `compute/env.tfvars/`.

When you run `terraform-apply.sh`, the script:
1. Detects the current **Terraform workspace**.
2. Automatically loads the corresponding `.tfvars` file.
3. Proceeds with `terraform apply`.

If the `.tfvars` file is missing, it will prompt you and safely exit.

---

## 🚀 Setup Instructions

### 1️⃣ Initialize Terraform
```bash
terraform init
```

### 2️⃣ Create or Select a Workspace
Workspaces isolate your environment states.

```bash
terraform workspace new dev
terraform workspace select dev
terraform workspace list
```

### 3️⃣ Verify Your `.tfvars` File
Make sure a matching `.tfvars` file exists in:
```
compute/env.tfvars/<workspace>.tfvars
```
Example:
```
compute/env.tfvars/dev.tfvars
```

---

## ▶️ Apply Infrastructure

Run the automated shell script:
```bash
bash terraform-apply.sh
```

Or manually:
```bash
terraform apply --auto-approve -var-file="env.tfvars/dev.tfvars"
```

---

## 💣 Destroy Infrastructure

Run the destroy shell script:
```bash
bash terraform-destroy.sh
```

Or manually:
```bash
terraform destroy --auto-approve -var-file="env.tfvars/dev.tfvars"
```

---

## 🧱 Example `.tfvars` File

```hcl
# If any of these variables are left empty, Terraform will use defaults
# from `variable.tf` or prompt for input.

exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"

current_project_tag       = "dev-environment"
instance_type             = "t2.micro"
confirm_dns_update        = "no"

enter_ami_name            = "ubuntu"
server_user               = "ubuntu"
instance_root_volume_size = "20"
allowed_ports             = [22, 80, 443]
instance_key_name         = "your_region_key"
```

---

## 🧩 Outputs

After a successful apply, Terraform prints the following outputs:
- `vpc_id_out` – VPC ID  
- `sg_id_out` – Security Group ID  
- `instance_id_out` – EC2 Instance ID  
- `instance_public_ip_out` – EC2 Public IP  

You can view them any time with:
```bash
terraform output
```

---

## 🧠 Tips

- To list all workspaces:
  ```bash
  terraform workspace list
  ```
- To check current workspace:
  ```bash
  terraform workspace show
  ```
- To update DNS entries, edit:  
  `scripts/dns_entry.sh`

---

## 📜 License
This project is maintained for DevOps learning and automation.  
You can reuse and modify it for your own infrastructure setups.

---

**Author:** Vijay Durai  
**Role:** DevOps & Cloud Engineer ☁️  
**Purpose:** Reusable Terraform AWS Infrastructure Automation

# 🧩 Terraform AWS Infrastructure Automation

This repository provisions AWS infrastructure (VPC, Security Groups, EC2 instances, etc.) using **Terraform** and modular design.

## 🆕 Recent Updates

- **Unified Script**: A single `terraform.sh` script now handles `plan`, `apply`, and `destroy` actions with automatic workspace detection.
- **Public/Private Instances**: New `external_access` variable allows creating private-only instances (no public IP, no external access).
- **Cleaner Repo**: `.gitignore` is updated to exclude sensitive `.tfvars` files (except `default.tfvars`).

---

## 📁 Project Structure

```
├── env/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.sh       <-- Unified execution script
│   └── variable.tf
│
├── env.tfvars/
│   ├── default.tfvars
│   ├── private.tfvars
│   ├── public.tfvars
│
├── modules/
│   ├── compute/
│   ├── sg/
│   └── vpc/
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

Each environment (workspace) has its own `.tfvars` file under `env.tfvars/`.

When you run `env/terraform.sh`, the script:
1. Detects the current **Terraform workspace**.
2. Automatically loads the corresponding `.tfvars` file (e.g., `env.tfvars/dev.tfvars`).
3. Defaults to `env.tfvars/default.tfvars` if a specific file isn't found.
4. Asks for confirmation before proceeding.

---

## 🚀 Setup Instructions

### 1️⃣ Initialize Terraform
```bash
cd env
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
Make sure a matching `.tfvars` file exists in `env.tfvars/`.

---

## ▶️ Use the Unified Script

We provided a simple script `env/terraform.sh` to manage your infrastructure.

### Plan
```bash
./terraform.sh plan
```

### Apply
```bash
./terraform.sh apply
```

### Destroy
```bash
./terraform.sh destroy
```

---

## 🌍 Public vs Private Instances

You can control whether an instance is **Public** or **Private** using the `external_access` variable in your `.tfvars` file.

```hcl
external_access = true  # Creates a Public Instance with Public IP & DNS entry
external_access = false # Creates a Private Instance (Internal access only)
```

### Example `.tfvars`

```hcl
exist_vpc_name            = "source-vpc"
exist_public_subnet_name  = "source-subnet-01"
exist_private_subnet_name = "source-subnet-02"

current_project_tag       = "dev-environment"
instance_type             = "t2.micro"
confirm_dns_update        = "yes"  # Only runs if external_access is true

external_access           = true

enter_ami_name            = "ubuntu"
server_user               = "ubuntu"
instance_root_volume_size = "20"
allowed_ports             = [22, 80, 443]
instance_key_name         = "your_region_key"
```

---

## 🧩 Outputs

After a successful apply, Terraform prints:
- `vpc_id_out` – VPC ID
- `sg_id_out` – Security Group ID
- `instance_id_out` – EC2 Instance ID
- `instance_public_ip_out` – EC2 Public IP (Empty for private instances)

---

## 📜 License
This project is maintained for DevOps learning and automation.
You can reuse and modify it for your own infrastructure setups.

---

## 🔑 Users and SSH Keys

You can add multiple users and their SSH keys using the `ssh_users` variable. These users will be granted `sudo` access by default.

### Example in `.tfvars`

```hcl
ssh_users = {
  "vijaydurai" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."
  "newuser"    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ..."
}
```

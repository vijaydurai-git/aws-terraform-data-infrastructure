# 🧩 Terraform AWS Infrastructure Automation

This repository provisions AWS infrastructure (VPC, Security Groups, EC2 instances) using **Terraform**. It features a modern, modular design with automated user provisioning, smart package installation, and dynamic DNS updates.

## 🆕 Key Features

*   **Unified Workspace Management**: A single `terraform.sh` script handles `plan`, `apply`, and `destroy` with automatic workspace detection.
*   **Public/Private Instances**: Controlled via `external_access`. Private instances are automatically configured without public IPs.
*   **Standardized Environments**: Consistent configuration across `admin`, `own`, `private`, `public` workspaces via strict `.tfvars` templates.
*   **Smart Provisioning**:
    *   **Dynamic Package Install**: `install_packages.sh` finds packages (e.g., `docker` -> `docker.io`) and installs them idempotently.
    *   **Idempotent DNS**: `dns_update.sh` checks Route53 before making API calls to prevent unnecessary updates.
*   **Logging**: Creation details and package installation status are logged locally to `instance_details.txt`.

---

## 📁 Project Structure

```bash
├── env/
│   ├── backend.tf          # State management
│   ├── main.tf             # Module orchestration
│   ├── outputs.tf          # Output definitions
│   ├── provider.tf         # AWS Provider config
│   ├── terraform.sh        # 🚀 Automation Script
│   └── variable.tf         # Environment variables
│
├── env.tfvars/
│   ├── admin.tfvars        # Admin environment config
│   ├── default.tfvars      # Default/Template config
│   ├── own.tfvars          # Personal environment config
│   ├── private.tfvars      # Private instance config
│   └── public.tfvars       # Public instance config
│
├── modules/
│   ├── compute/            # EC2, User Data, Provisioners
│   ├── sg/                 # Security Groups
│   └── vpc/                # VPC & Subnet DataSource
│
├── scripts/
│   ├── aws_cli.sh          # AWS CLI setup
│   ├── crontab-e.sh        # Cron job configuration
│   ├── dns_update.sh       # 🔄 Idempotent Route53 Update
│   └── install_packages.sh # 📦 Smart Package Installer
│
└── README.md
```

---

## 🛑 READ BEFORE STARTING

### `external_access` Setting
*   `true` = Launch Public Instance (Direct Internet Access)
*   `false` = Launch Private Instance (Requires NAT Gateway)

> [!IMPORTANT]
> If setting to **false** (Private), you **MUST** ensure the NAT Gateway is active and running. This is managed separately in the VPC module.
> Refer to: [AWS Terraform Only VPC](https://github.com/git-vijaydurai/aws-terraform-only-vpc.git)

---

## 🚀 Usage Commands

### Option 1: Automation Script (Recommended)
```bash
./terraform.sh
# (Follow the interactive prompts for Plan, Apply, or Destroy)
```

### Option 2: Manual Commands
```bash
terraform workspace list
terraform workspace new <env>
terraform workspace select <env>
terraform plan -var-file="../env.tfvars/$(terraform workspace show).tfvars"
terraform apply -var-file="../env.tfvars/$(terraform workspace show).tfvars" --auto-approve
terraform destroy -var-file="../env.tfvars/$(terraform workspace show).tfvars" --auto-approve
```

---

## ⚙️ Configuration Variables

Configuration is managed via `.tfvars` files. Key variables include:

### Core Settings
| Variable | Description |
| :--- | :--- |
| `external_access` | `true` = Public Instance (Public IP). `false` = Private Instance (Internal Only). |
| `instance_type` | EC2 Instance Type (e.g., `t3.small`). |
| `server_user` | Default AMI user (e.g., `ubuntu`). Used for initial connection. |

### Advanced Features
| Variable | Description |
| :--- | :--- |
| `run_dns_update_file` | Set to `"yes"` to run `dns_update.sh`. **Only runs if `external_access = true`.** |
| `packages_to_install` | List of packages (e.g., `["docker", "zip"]`). The smart installer handles naming mapping automatically. |
| `ssh_users` | Map of users and public keys to create on the instance. |
| `aws_backup_bucket_name` | S3 bucket name for backups (triggered on destroy). |



---

## 🛠️ Scripts & Automation

### 📦 Smart Package Installation (`install_packages.sh`)
*   **Dynamic Discovery**: You can list generic names like `docker` or `java`. The script searches the repo (`apt-cache`/`yum search`) to find the correct package name (e.g., `docker.io`, `default-jdk`).
*   **Idempotency**: Checks if a package is installed (`dpkg -s`/`rpm -q`) before attempting installation.
*   **Logging**: Logs "Package Installation SUCCESSFUL" to `instance_details.txt` on your local machine.


### 🔄 Idempotent DNS Update (`dns_update.sh`)
*   **Smart Check**: Queries Route53 to check the current record before sending an update.
*   **No Spam**: Only sends an `UPSERT` request if the ID actually changed.

### 💾 Auto Shutdown Backup
*   **Trigger**: Automatically triggered during `terraform destroy`.
*   **Function**: Zips the home directory of the specified `backup_user` and uploads it to S3.
*   **Reliability**:
    *   **Fail-Safe**: Uses `on_failure = continue` to ensure `terraform destroy` completes even if the instance is unreachable (e.g., already terminated).
    *   **Timeout**: Connection attempts timeout after 1 minute to prevent indefinite hanging.


---

## 📝 Logs

Check `instance_details.txt` in the root directory for a log of:
*   Instance Creation (Name, IP, Timestamp)
*   Package Installation Status

---

## 📜 License
Maintained for DevOps automation and learning.

---

## 👨‍💻 Author

**Vijaydurai**  
*Cloud and DevOps Engineer*

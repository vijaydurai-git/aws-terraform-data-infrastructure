#!/bin/bash

# Get the current workspace
WORKSPACE=$(terraform workspace show)

# Define the tfvars file dynamically
TFVARS_FILE="/home/e1087/devops/awsInfra/compute/env.tfvars/${WORKSPACE}.tfvars"

# Check if the file exists
if [ -f "$TFVARS_FILE" ]; then
    echo -e "\n=============================================="
    echo -e "  Using \e[1;32m$TFVARS_FILE\e[0m for workspace \e[1;34m$WORKSPACE\e[0m"
    echo -e "==============================================\n"

    read -p "Press Enter to continue or Ctrl+C to cancel... "

    terraform destroy -var-file="$TFVARS_FILE"
else

    echo -e "\n❌ No \e[1;31m$WORKSPACE.tfvars\e[0m file found for workspace \e[1;34m$WORKSPACE\e[0m.\n"

fi
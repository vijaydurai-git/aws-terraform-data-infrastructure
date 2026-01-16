#!/bin/bash

# Simple Terraform Runner

# 1. Get the action (plan, apply, destroy)
ACTION=$1

if [ -z "$ACTION" ]; then
    echo "Please provide an action: plan, apply, or destroy"
    exit 1
fi

# 2. Find the variables file
WORKSPACE=$(terraform workspace show)
TFVARS_FILE="../env.tfvars/${WORKSPACE}.tfvars"

# Use default if workspace specific file missing
if [ ! -f "$TFVARS_FILE" ]; then
    TFVARS_FILE="../env.tfvars/default.tfvars"
fi

# 3. Confirm and Run
echo "Running terraform $ACTION for $WORKSPACE..."
echo "Using variables: $TFVARS_FILE"
echo "...$WORKSPACE..is currently selected workspace"

terraform $ACTION -var-file="$TFVARS_FILE"

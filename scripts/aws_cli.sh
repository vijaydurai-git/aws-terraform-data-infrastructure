#!/bin/bash

curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Detect the operating system and install 'unzip' accordingly

if [ -f /etc/debian_version ]; then
    echo "Detected Debian-based system. Installing 'unzip' with apt."
    sudo apt update -y && sudo apt install unzip -y

elif [ -f /etc/redhat-release ]; then
    echo "Detected RHEL-based system. Installing 'unzip' with yum."
    sudo yum install unzip -y

elif [ -f /etc/os-release ] && grep -qi "amazon" /etc/os-release; then
    echo "Detected Amazon Linux. Installing 'unzip' with yum."
    sudo yum install unzip -y
else
    echo "Unsupported OS. Installation aborted."
    exit 1
fi

# Confirm installation success
if ! command -v unzip &> /dev/null; then
    echo "Unzip installation failed. Aborting."
    exit 1
fi

unzip -q awscliv2.zip || { echo "Unzip failed. Aborting."; exit 1; }
sudo ./aws/install || { echo "AWS CLI installation failed. Aborting."; exit 1; }

echo "AWS CLI installation completed successfully."

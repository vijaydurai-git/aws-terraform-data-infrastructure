#!/bin/bash

setup_cron() {
    echo "Checking OS type..."
    
    # Detect OS type
    if [[ -f /etc/debian_version ]]; then
        OS="Debian"
        INSTALL_CMD="sudo apt update && sudo apt install -y cron"
        SERVICE_CMD="sudo systemctl enable cron && sudo systemctl start cron"
    elif [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
        OS="RHEL"
        INSTALL_CMD="sudo yum install -y cronie"
        SERVICE_CMD="sudo systemctl enable crond && sudo systemctl start crond"
    else
        echo "Unsupported OS!"
        exit 1
    fi

    echo "Detected OS: $OS"

    # Install cron if not installed
    echo "Checking if cron is installed..."
    if ! command -v crontab &>/dev/null; then
        echo "Installing cron..."
        eval "$INSTALL_CMD"
    else
        echo "Cron is already installed."
    fi

    # Enable and start cron service
    echo "Starting and enabling cron service..."
    eval "$SERVICE_CMD"

    # Check if cron service is running
    if systemctl is-active --quiet cron || systemctl is-active --quiet crond; then
        echo "Cron service is running."
    else
        echo "Cron service failed to start!"
        exit 1
    fi

    # Define cron job
    CRON_JOB="@reboot /bin/bash /home/$USER/dns_entry.sh"

    # Add cron job if not exists
    (crontab -l 2>/dev/null | grep -Fxq "$CRON_JOB") || (echo "$CRON_JOB" | crontab -)

    echo "Cron job added. Current crontab:"
    crontab -l
}

# Run the function
setup_cron

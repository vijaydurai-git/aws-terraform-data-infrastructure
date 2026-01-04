#!/bin/bash

USER_NAME="$1"
PUBLIC_KEY="$2"

if [ -z "$USER_NAME" ] || [ -z "$PUBLIC_KEY" ]; then
  echo "Usage: $0 <username> <public_key>"
  exit 1
fi

# Create user if not exists
if id -u "$USER_NAME" >/dev/null 2>&1; then
    echo "User $USER_NAME already exists."
else
    echo "Creating user $USER_NAME..."
    # Create group if not exists
    if ! getent group tf-users > /dev/null; then
        sudo groupadd tf-users
    fi
    sudo useradd -m -s /bin/bash -G tf-users "$USER_NAME"
    echo "User $USER_NAME created and added to tf-users group."
fi

# Add to sudoers
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$USER_NAME

# Setup SSH key
USER_HOME="/home/$USER_NAME"
SSH_DIR="$USER_HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"

sudo mkdir -p "$SSH_DIR"
echo "$PUBLIC_KEY" | sudo tee "$AUTHORIZED_KEYS" > /dev/null

sudo chmod 700 "$SSH_DIR"
sudo chmod 600 "$AUTHORIZED_KEYS"
sudo chown -R "$USER_NAME:$USER_NAME" "$SSH_DIR"

echo "SSH key added for $USER_NAME."

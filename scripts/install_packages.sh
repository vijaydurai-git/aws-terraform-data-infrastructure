#!/bin/bash

# Configuration
PACKAGES=("$@")

if [ ${#PACKAGES[@]} -eq 0 ]; then
    echo "[INFO] No packages specified to install."
    exit 0
fi

echo "[INFO] Starting dynamic package installation check..."

# Detect Package Manager
if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt"
    sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
else
    echo "[ERROR] No supported package manager found (apt-get/yum)."
    exit 1
fi

for pkg_input in "${PACKAGES[@]}"; do
    
    echo "[INFO] Processing request: $pkg_input"
    TARGET_PKG=""

    # 1. Dynamic Discovery
    if [ "$PKG_MANAGER" == "apt" ]; then
        # Check if exact match exists in cache
        if apt-cache show "$pkg_input" &> /dev/null; then
            TARGET_PKG="$pkg_input"
        else
            echo "[INFO] Exact match for '$pkg_input' not found. Searching repository..."
            # Search for best match (head -n 1 takes the first result)
            SEARCH_RESULT=$(apt-cache search --names-only "^$pkg_input" | head -n 1 | awk '{print $1}')
            if [ -n "$SEARCH_RESULT" ]; then
                TARGET_PKG="$SEARCH_RESULT"
                echo "[INFO] Found candidate: $TARGET_PKG"
            else
                echo "[WARN] No package found matching '$pkg_input' in repository."
                continue
            fi
        fi

        # 2. Idempotency Check (Debian)
        if dpkg -s "$TARGET_PKG" &> /dev/null; then
            echo "[SUCCESS] $TARGET_PKG is already installed. Skipping."
            continue
        fi

        # 3. Install
        echo "[INFO] Installing $TARGET_PKG..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$TARGET_PKG"

    elif [ "$PKG_MANAGER" == "yum" ]; then
        # Check if exact match exists
        if yum list available "$pkg_input" &> /dev/null || yum list installed "$pkg_input" &> /dev/null; then
            TARGET_PKG="$pkg_input"
        else
            echo "[INFO] Exact match for '$pkg_input' not found. Searching repository..."
            # Search for best match
            SEARCH_RESULT=$(yum search "$pkg_input" -q | grep -v "=" | head -n 1 | awk '{print $1}')
            if [ -n "$SEARCH_RESULT" ]; then
                TARGET_PKG="$SEARCH_RESULT"
                echo "[INFO] Found candidate: $TARGET_PKG"
            else
                 echo "[WARN] No package found matching '$pkg_input' in repository."
                 continue
            fi
        fi

        # 2. Idempotency Check (RHEL)
        if rpm -q "$TARGET_PKG" &> /dev/null; then
            echo "[SUCCESS] $TARGET_PKG is already installed. Skipping."
            continue
        fi

        # 3. Install
        echo "[INFO] Installing $TARGET_PKG..."
        sudo yum install -y "$TARGET_PKG"
    fi

    echo "[SUCCESS] $TARGET_PKG installed successfully."

done

echo "[INFO] Package installation sequence completed."

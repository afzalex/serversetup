#!/bin/bash
# Setup lsyncd for file synchronization
# Ref: https://github.com/lsyncd/lsyncd

# Install lsyncd if not already installed
if ! command -v lsyncd &> /dev/null; then
    echo "Installing lsyncd..."
    sudo apt-get update
    sudo apt-get install -y lsyncd
fi

# Create log directory
sudo mkdir -p /var/log/lsyncd

# Create log and status files
sudo touch /var/log/lsyncd/lsyncd.log
sudo touch /var/log/lsyncd/lsyncd.status
sudo chmod 644 /var/log/lsyncd/lsyncd.log
sudo chmod 644 /var/log/lsyncd/lsyncd.status

# Create config directory if it doesn't exist
sudo mkdir -p /etc/lsyncd

CONFIG_FILE="/etc/lsyncd/lsyncd.conf.lua"

# Function to add a sync entry
add_sync_entry() {
    # Prompt for source directory
    while true; do
        echo ""
        read -p "Source directory to sync from (e.g., /home/user/documents or ~/documents): " SOURCE_DIR
        if [ -z "$SOURCE_DIR" ]; then
            echo "Error: Source directory is required"
            continue
        fi
        
        # Expand ~ and resolve path
        SOURCE_DIR=$(eval echo "$SOURCE_DIR")
        SOURCE_DIR=$(realpath -m "$SOURCE_DIR" 2>/dev/null || echo "$SOURCE_DIR")
        
        # Validate source directory exists
        if [ ! -d "$SOURCE_DIR" ]; then
            echo "Error: Source directory '$SOURCE_DIR' does not exist."
            read -p "Do you want to create it? (y/n): " CREATE_SOURCE
            if [ "$CREATE_SOURCE" = "y" ] || [ "$CREATE_SOURCE" = "Y" ]; then
                mkdir -p "$SOURCE_DIR"
                echo "Created source directory: $SOURCE_DIR"
                break
            else
                continue
            fi
        else
            echo "Source directory validated: $SOURCE_DIR"
            break
        fi
    done
    
    # Prompt for target directory
    while true; do
        echo ""
        read -p "Target directory to sync to (e.g., /backup/documents or ~/backup): " TARGET_DIR
        if [ -z "$TARGET_DIR" ]; then
            echo "Error: Target directory is required"
            continue
        fi
        
        # Expand ~ and resolve path
        TARGET_DIR=$(eval echo "$TARGET_DIR")
        TARGET_DIR=$(realpath -m "$TARGET_DIR" 2>/dev/null || echo "$TARGET_DIR")
        
        # Create target directory if it doesn't exist
        if [ ! -d "$TARGET_DIR" ]; then
            echo "Target directory '$TARGET_DIR' does not exist."
            read -p "Do you want to create it? (y/n): " CREATE_TARGET
            if [ "$CREATE_TARGET" = "y" ] || [ "$CREATE_TARGET" = "Y" ]; then
                sudo mkdir -p "$TARGET_DIR"
                echo "Created target directory: $TARGET_DIR"
                break
            else
                continue
            fi
        else
            echo "Target directory validated: $TARGET_DIR"
            break
        fi
    done
    
    # Check if sync already exists
    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "sync\{" "$CONFIG_FILE" && grep -q "\"$SOURCE_DIR\"" "$CONFIG_FILE" && grep -q "\"$TARGET_DIR\"" "$CONFIG_FILE"; then
            echo ""
            echo "Warning: A sync entry for '$SOURCE_DIR' -> '$TARGET_DIR' already exists in the configuration."
            return 1
        fi
    fi
    
    # Add sync entry
    if [ -f "$CONFIG_FILE" ]; then
        # Config file exists, just add sync entry
        sudo tee -a "$CONFIG_FILE" > /dev/null <<EOF

sync{
    default.rsync,
    source="$SOURCE_DIR",
    target="$TARGET_DIR",
}
EOF
        echo "Sync entry added: $SOURCE_DIR -> $TARGET_DIR"
    else
        # Config file doesn't exist, create full configuration
        sudo tee "$CONFIG_FILE" > /dev/null <<EOF
-- User configuration file for lsyncd.
--
-- This is a Lua file, and you can use all Lua features.
-- See the Lua manual for more information.
--
-- Lua 5.1 is the default Lua version.

settings {
    logfile = "/var/log/lsyncd/lsyncd.log",
    statusFile = "/var/log/lsyncd/lsyncd.status",
    nodaemon = false,
}

sync{
    default.rsync,
    source="$SOURCE_DIR",
    target="$TARGET_DIR",
}
EOF
        echo "Configuration file created with sync entry: $SOURCE_DIR -> $TARGET_DIR"
    fi
    
    return 0
}

# Main interactive loop
echo ""
echo "=== lsyncd Sync Configuration ==="
echo ""

# Add first sync entry
add_sync_entry

# Ask if user wants to add more sync entries
if [ -f "$CONFIG_FILE" ]; then
    while true; do
        echo ""
        read -p "Do you want to add another sync entry? (y/n): " ADD_MORE
        if [ "$ADD_MORE" != "y" ] && [ "$ADD_MORE" != "Y" ]; then
            break
        fi
        add_sync_entry
    done
fi

# Restart lsyncd service
echo "Restarting lsyncd service..."
sudo systemctl daemon-reload
sudo systemctl restart lsyncd
sudo systemctl enable lsyncd

# Show status
echo ""
echo "lsyncd service status:"
sudo systemctl status lsyncd --no-pager -l

echo ""
echo "Configuration file location: $CONFIG_FILE"
echo "Log file: /var/log/lsyncd/lsyncd.log"
echo "Status file: /var/log/lsyncd/lsyncd.status"


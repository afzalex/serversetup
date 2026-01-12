#!/bin/bash
# Setup lsyncd for file synchronization
# Ref: https://github.com/lsyncd/lsyncd

# Enable tab completion for paths in readline
if [ -n "$BASH_VERSION" ]; then
    # Enable readline completion
    bind 'set completion-ignore-case on' 2>/dev/null || true
    bind 'set show-all-if-ambiguous on' 2>/dev/null || true
    bind 'set show-all-if-unmodified on' 2>/dev/null || true
    # Enable filename completion
    bind '"\t": complete' 2>/dev/null || true
fi

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
        echo "Tip: Use Tab for path completion (double-tab to see options)"
        # Use read -e to enable readline editing (supports tab completion)
        read -e -p "Source directory to sync from (e.g., /home/user/documents or ~/documents): " SOURCE_DIR
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
    
    # Prompt for target type (SSH only)
    echo ""
    echo "Target will be synced over SSH."
    
    # Prompt for SSH host
    while true; do
        echo ""
        read -e -p "SSH host (e.g., user@hostname.local or user@192.168.1.100): " SSH_HOST
        if [ -z "$SSH_HOST" ]; then
            echo "Error: SSH host is required"
            continue
        fi
        echo "SSH host validated: $SSH_HOST"
        break
    done
    
    # Prompt for target directory on remote host
    while true; do
        echo ""
        read -e -p "Target directory on remote host (e.g., ./sources/fzdocker/immich/library/ or /backup/documents): " TARGET_DIR
        if [ -z "$TARGET_DIR" ]; then
            echo "Error: Target directory is required"
            continue
        fi
        echo "Target directory: $TARGET_DIR"
        break
    done
    
    # Prompt for SSH identity file
    while true; do
        echo ""
        read -e -p "SSH identity file (e.g., /home/user/.ssh/id_ed25519) [default: /home/$USER/.ssh/id_ed25519]: " SSH_IDENTITY
        if [ -z "$SSH_IDENTITY" ]; then
            SSH_IDENTITY="/home/$USER/.ssh/id_ed25519"
        fi
        
        # Expand ~ and resolve path
        SSH_IDENTITY=$(eval echo "$SSH_IDENTITY")
        SSH_IDENTITY=$(realpath -m "$SSH_IDENTITY" 2>/dev/null || echo "$SSH_IDENTITY")
        
        # Validate SSH identity file exists
        if [ ! -f "$SSH_IDENTITY" ]; then
            echo "Warning: SSH identity file '$SSH_IDENTITY' does not exist."
            read -p "Do you want to continue anyway? (y/n): " CONTINUE_SSH
            if [ "$CONTINUE_SSH" != "y" ] && [ "$CONTINUE_SSH" != "Y" ]; then
                continue
            fi
        fi
        echo "SSH identity file: $SSH_IDENTITY"
        break
    done
    
    # Prompt for rsync path on remote host (optional)
    echo ""
    read -e -p "rsync path on remote host (e.g., /opt/homebrew/bin/rsync) [optional, press Enter to skip]: " RSYNC_PATH
    if [ -z "$RSYNC_PATH" ]; then
        RSYNC_PATH="rsync"
    fi
    echo "rsync path: $RSYNC_PATH"
    
    # Check if sync already exists
    if [ -f "$CONFIG_FILE" ]; then
        if grep -q "sync\{" "$CONFIG_FILE" && grep -q "\"$SOURCE_DIR\"" "$CONFIG_FILE" && grep -q "\"$SSH_HOST\"" "$CONFIG_FILE"; then
            echo ""
            echo "Warning: A sync entry for '$SOURCE_DIR' -> '$SSH_HOST:$TARGET_DIR' already exists in the configuration."
            return 1
        fi
    fi
    
    # Build rsync _extra options
    if [ "$RSYNC_PATH" != "rsync" ]; then
        RSYNC_EXTRA="\"--rsync-path=$RSYNC_PATH\",
                    \"--inplace\", 
                    \"--partial\","
    else
        RSYNC_EXTRA="\"--inplace\", 
                    \"--partial\","
    fi
    
    # Add sync entry
    if [ -f "$CONFIG_FILE" ]; then
        # Config file exists, just add sync entry
        sudo tee -a "$CONFIG_FILE" > /dev/null <<EOF

sync{
    default.rsyncssh,
    source="$SOURCE_DIR",
    host="$SSH_HOST",
    targetdir="$TARGET_DIR",
    rsync={
            archive=true,
            compress=true,
            _extra={
                    $RSYNC_EXTRA
            },
    },
    ssh={
            identityFile="$SSH_IDENTITY",
    },
}
EOF
        echo "Sync entry added: $SOURCE_DIR -> $SSH_HOST:$TARGET_DIR"
    else
        # Build rsync _extra options for new config
        if [ "$RSYNC_PATH" != "rsync" ]; then
            RSYNC_EXTRA_NEW="\"--rsync-path=$RSYNC_PATH\",
                    \"--inplace\", 
                    \"--partial\","
        else
            RSYNC_EXTRA_NEW="\"--inplace\", 
                    \"--partial\","
        fi
        
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
    default.rsyncssh,
    source="$SOURCE_DIR",
    host="$SSH_HOST",
    targetdir="$TARGET_DIR",
    rsync={
            archive=true,
            compress=true,
            _extra={
                    $RSYNC_EXTRA_NEW
            },
    },
    ssh={
            identityFile="$SSH_IDENTITY",
    },
}
EOF
        echo "Configuration file created with sync entry: $SOURCE_DIR -> $SSH_HOST:$TARGET_DIR"
    fi
    
    # Run initial rsync sync
    echo ""
    echo "Running initial rsync sync..."
    
    # Ensure source directory has trailing slash for rsync
    SOURCE_DIR_RSYNC="$SOURCE_DIR"
    if [[ ! "$SOURCE_DIR_RSYNC" =~ /$ ]]; then
        SOURCE_DIR_RSYNC="$SOURCE_DIR_RSYNC/"
    fi
    
    # Build full target path
    FULL_TARGET_PATH="$SSH_HOST:$TARGET_DIR"
    
    # Build rsync command
    RSYNC_CMD="rsync -aH --info=stats2,progress2"
    if [ "$RSYNC_PATH" != "rsync" ]; then
        RSYNC_CMD="$RSYNC_CMD --rsync-path=$RSYNC_PATH"
    fi
    RSYNC_CMD="$RSYNC_CMD -e \"ssh -i $SSH_IDENTITY\""
    RSYNC_CMD="$RSYNC_CMD \"$SOURCE_DIR_RSYNC\""
    RSYNC_CMD="$RSYNC_CMD \"$FULL_TARGET_PATH\""
    
    echo "Executing: $RSYNC_CMD"
    eval "$RSYNC_CMD"
    
    if [ $? -eq 0 ]; then
        echo "Initial rsync sync completed successfully."
    else
        echo "Warning: Initial rsync sync completed with errors. Please check the output above."
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


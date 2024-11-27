#!/bin/bash
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

get_keyboard_id_robust() {
    local keyboard_name="AT Translated Set 2 keyboard"
    local id
    id=$(xinput list | grep -F "$keyboard_name" | grep -oP 'id=\K\d+')
    if [ -z "$id" ]; then
        echo "Error: Keyboard '$keyboard_name' not found" >&2
        return 1
    fi
    echo "$id"
    return 0
}

toggle_keyboard() {
    local current_state
    read -r current_state <$fconfig
    
    if [ "$current_state" = "disabled" ]; then
        update_notification "Enabled" "$Icon" "ON - Keyboard connected!"
        echo "enable keyboard..."
        xinput enable "$keyboard_id"
        echo "enabled" >$fconfig
    elif [ "$current_state" = "enabled" ]; then
        update_notification "Disabled" "$Icoff" "OFF - Keyboard disconnected"
        echo "disable keyboard"
        xinput disable "$keyboard_id"
        echo 'disabled' >$fconfig
    fi
}

update_notification() {
    local status=$1
    local icon=$2
    local message=$3
    
    # Kill existing notification
    pkill -f "yad --notification.*keyboard-status"
    
    # Show new persistent notification with menu and left-click action
    yad --notification \
        --image="$icon" \
        --text="Keyboard $status" \
        --menu="Exit!quit" \
        --command="$SCRIPT_DIR/$(basename $0)" \
        --listen \
        --class="keyboard-status" &
        
    # Also show temporary notification
    notify-send -i "$icon" "Keyboard Status" "$message"
}

# Kill existing yad process if any
pkill -f "yad --notification.*keyboard-status"

Icon="$SCRIPT_DIR/enable.png"
Icoff="$SCRIPT_DIR/disable.png"
fconfig=".keyboard"
keyboard_id=$(get_keyboard_id_robust)

# Initialize config file if it doesn't exist
if [ ! -f $fconfig ]; then
    echo "Creating config file"
    echo "enabled" >$fconfig
fi

# Check if script is being called from yad click
if [ -n "$YAD_PID" ]; then
    toggle_keyboard
else
    # Initial setup
    read -r var <$fconfig
    echo "keyboard is : $var"
    if [ "$var" = "enabled" ]; then
        update_notification "Enabled" "$Icon" "ON - Keyboard connected!"
    else
        update_notification "Disabled" "$Icoff" "OFF - Keyboard disconnected"
    fi
fi

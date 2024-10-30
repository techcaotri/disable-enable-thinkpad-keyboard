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

Icon="$SCRIPT_DIR/enable.png"
Icoff="$SCRIPT_DIR/disable.png"
fconfig=".keyboard"
id=$(get_keyboard_id_robust)

if [ ! -f $fconfig ]; then
	echo "Creating config file"
	echo "enabled" >$fconfig
	var="enabled"
else
	read -r var <$fconfig
	echo "keyboard is : $var"
fi

if [ "$var" = "disabled" ]; then
	notify-send -i $Icon "Enabling keyboard..." \ "ON - Keyboard connected !"
	echo "enable keyboard..."
	xinput enable $id
	echo "enabled" >$fconfig
elif [ "$var" = "enabled" ]; then
	notify-send -i $Icoff "Disabling Keyboard" \ "OFF - Keyboard disconnected"
	echo "disable keyboard"
	xinput disable $id
	echo 'disabled' >$fconfig
fi

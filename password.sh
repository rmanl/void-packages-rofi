#!/bin/sh

# Take password prompt from STDIN, print password to STDOUT
# the sed piece just removes the colon from the provided
# prompt: rofi -p already gives us a colon
rofi -dmenu \
	-password \
	-no-fixed-num-lines \
	-theme ~/void-packages-rofi/configs/password.rasi \
	-p "󰢁" \
	-p "$(printf "$1" | sed s/://)"

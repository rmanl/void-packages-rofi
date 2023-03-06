#!/bin/bash
DIR=$HOME/.local/pkgs/void-packages
ROFI_CONFIG=$HOME/void-packages-rofi/configs/pkgs.rasi
ROFI_CONFIG_ARG=$HOME/void-packages-rofi/configs/
PASSWORD_PATH=$HOME/void-packages-rofi/

menu() {
	if [[ $# -gt 1 ]]; then
		rofi -config "$ROFI_CONFIG_ARG""$1.rasi" -dmenu -p " $2"
	else
		rofi -config "$ROFI_CONFIG" -dmenu -p " $1"
	fi
}

notify() {
	if [[ $# -gt 1 ]]; then
		notify-send -u normal -t 3000 "$1" "$(echo -e "$2")" -a Void-Packages
	else
		notify-send -u normal -t 3000 "$(echo -e "$1")" -a Void-Packages
	fi
}

init_menu() {
	local options
	options="Update repo\nInstall package\nList installed packages"
	printf "%b" "$options" | menu "Void Packages"
}

update_repo() {
	REPO=$(git status -s -u no)
	if [[ "$REPO" = "" ]]; then
		notify "Repo already up to date"
	else
		cd "$DIR" || exit
		git pull
		notify "Repo updated"
	fi
}

compare() {
	CHECK="$(xbps-query -s $PKG | awk '{print $2}')"
	VERSION="$(perl -lne 'print $1 if /^version=\s*(.*)/' $DIR/srcpkgs/"$PKG"/template)"
	if [[ "$CHECK" =~ "$PKG-$VERSION" ]]; then
		notify "$PKG" "Already installed"
	else
        PASSWORD=$($PASSWORD_PATH"password.sh")
		install
	fi
}

check() {
	CHECK="$(xbps-query -s $PKG | awk '{print $2}')"
	if [[ "$CHECK" =~ "$PKG-$VERSION" ]]; then
		notify "$PKG" "Installed"
	else
		notify "$PKG" "Failed to install"
	fi
}

install() {
	cd "$DIR"/srcpkgs
	if [[ -d "$PKG" ]]; then
		cd "$DIR" || exit
		notify "$PKG" "Installing..."
		footclient ./xbps-src pkg "$PKG" && echo -e "$PASSWORD" | sudo -S xbps-install -y --repository hostdir/binpkgs "$PKG"
		check
	else
		notify "$PKG" "Package not found"
	fi
}

install_menu() {
	PKG="$(ls "$DIR"/srcpkgs | menu "tall" "Install package")"
	compare
}

main() {
	case "$(init_menu)" in
	"Update repo")
		update_repo
		main
		;;
	"Install package")
		install_menu
		main
		;;
	"List installed packages")
		xbps-query -l | awk '{ print $2 }' | xargs -n1 xbps-uhelper getpkgname | menu "tall2" "Installed packages"
		main
		;;
	esac
}

main

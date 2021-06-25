#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi
mkdir -p /usr/share/wgnord
cp template.conf countries.txt /usr/share/wgnord
cp wgnord /bin/

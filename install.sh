#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi
conf_dir=/usr/share/wgnord
mkdir -p $conf_dir
cp template.conf countries.txt $conf_dir
cp wgnord /bin/

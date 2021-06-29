#!/bin/sh
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi
conf_dir=/var/lib/wgnord
mkdir -p $conf_dir
chmod 770 $conf_dir
cp template.conf countries.txt $conf_dir
cp wgnord /bin/

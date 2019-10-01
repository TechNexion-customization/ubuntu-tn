#!/bin/sh

COL_GREEN="\e[1;32m"
COL_NORMAL="\e[m"

echo "${COL_GREEN}Technexion customized minimal rootfs staring...${COL_NORMAL}"
echo "${COL_GREEN}creating ubuntu sudoer account...${COL_NORMAL}"
cd /
echo technexion > /etc/hostname
(echo "ubuntu"; echo "ubuntu"; echo;) | adduser ubuntu
usermod -aG sudo ubuntu

echo "${COL_GREEN}apt-get server upgrading...${COL_NORMAL}"
# apt-get source adding
cat <<END > /etc/apt/sources.list
deb http://ports.ubuntu.com/ubuntu-ports/ bionic main
deb http://ports.ubuntu.com/ubuntu-ports/ bionic universe
deb http://ports.ubuntu.com/ubuntu-ports/ bionic multiverse
deb http://ports.ubuntu.com/ubuntu-ports/ bionic-backports main
deb http://ports.ubuntu.com/ubuntu-ports/ bionic-security main
END

# apt-get source update and installation
sudo apt-get update
yes "Y" | apt install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools bluez ppp ntp ntpdate bridge-utils
yes "Y" | apt install bash-completion

echo "${COL_GREEN}Add swap partition...Default size is 1GB${COL_NORMAL}"
dd if=/dev/zero of=/swapfile bs=1M count=1000
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# GUI desktop support
if [[ "$1" == "gui" ]];then
yes "Y" | apt install xfce4 lightdm onboard
rm /usr/share/lightdm/lightdm.conf.d/50-unity-greeter.conf
touch /usr/share/lightdm/lightdm.conf.d/50-xfce-greeter.conf
cat <<END > /usr/share/lightdm/lightdm.conf.d/50-xfce-greeter.conf
[SeatDefaults]
greeter-session=unity-greeter
user-session=xfce
allow-guest=false
autologin-user=ubuntu
autologin-user-timeout=0
END
fi


# clear the patches
rm -rf var/cache/apt/archives/*

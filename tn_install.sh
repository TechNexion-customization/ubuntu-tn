#!/bin/bash

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

echo "${COL_GREEN}Add swap partition...Default size is 256MB${COL_NORMAL}"
dd if=/dev/zero of=/swapfile bs=1M count=256
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# GUI desktop support
if [[ "$1" == "gui" ]];then
yes "Y" | apt install xfce4 lightdm onboard glmark2 xterm xfce4-screenshooter rfkill alsa-utils ubuntu-restricted-extras
yes "Y" | apt install $(awk 'BEGIN { ORS = " " } { print }' /usr/bin/apt_list)

yes "Y" | apt remove xscreensaver gnome-terminal
yes "Y" | apt-get autoremove

sudo systemctl enable tn_init
sudo systemctl start tn_init


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

mkdir -p /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/xfconf/
chown ubuntu:ubuntu /home/ubuntu/.config/xfce4/
chown ubuntu:ubuntu /home/ubuntu/.config/
touch /home/ubuntu/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
cat <<END > /home/ubuntu/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="empty"/>
    <property name="IconThemeName" type="empty"/>
    <property name="DoubleClickTime" type="empty"/>
    <property name="DoubleClickDistance" type="empty"/>
    <property name="DndDragThreshold" type="empty"/>
    <property name="CursorBlink" type="empty"/>
    <property name="CursorBlinkTime" type="empty"/>
    <property name="SoundThemeName" type="empty"/>
    <property name="EnableEventSounds" type="empty"/>
    <property name="EnableInputFeedbackSounds" type="empty"/>
  </property>
  <property name="Xft" type="empty">
    <property name="DPI" type="empty"/>
    <property name="Antialias" type="empty"/>
    <property name="Hinting" type="empty"/>
    <property name="HintStyle" type="empty"/>
    <property name="RGBA" type="empty"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="CanChangeAccels" type="empty"/>
    <property name="ColorPalette" type="empty"/>
    <property name="FontName" type="string" value="Sans 15"/>
    <property name="MonospaceFontName" type="empty"/>
    <property name="IconSizes" type="empty"/>
    <property name="KeyThemeName" type="empty"/>
    <property name="ToolbarStyle" type="empty"/>
    <property name="ToolbarIconSize" type="empty"/>
    <property name="MenuImages" type="empty"/>
    <property name="ButtonImages" type="empty"/>
    <property name="MenuBarAccel" type="empty"/>
    <property name="CursorThemeName" type="empty"/>
    <property name="CursorThemeSize" type="empty"/>
    <property name="DecorationLayout" type="empty"/>
  </property>
</channel>
END

chown ubuntu:ubuntu /home/ubuntu/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

yes "Y" | apt install --reinstall network-manager
fi

# clear the patches
rm -rf var/cache/apt/archives/*

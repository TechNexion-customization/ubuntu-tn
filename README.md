Technexion Ubuntu Root Filesystem Creator
===========================

## Overview
--------
Ubuntu rootfs(Root Filesystem) creator is a set of bash scripts, that help the
users to produce a customized ubuntu image using Cananical unique tool named `debootstrap`,
then adapt QEMU to config custom packages and tools on host PC.


## Host PC Environment Setup
--------
General Packages Installation ( Ubuntu 16.04 or above)

    $ sudo apt-get install apt-get install debootstrap qemu-system-arm qemu-user-static


## Starting Create Custom Rootfs
--------

Create a workspace folder then download Technexion Ubuntu Rootfs Creator:

    $ mkdir ubuntu_rootfs
    $ cd ubuntu_rootfs
    $ git clone https://github.com/TechNexion-customization/ubuntu-tn.git cookers

Source the rootfs creator for your target plaform, Default OS is Ubuntu 18.04 LTS:

    For IMX6 with Ubuntu Terminal
    $ source cookers/env.bash.imx6.terminal

    For IMX6 with Ubuntu XFCE Desktop (HW accleration)
    $ source cookers/env.bash.imx6.xfce

    For IMX7 with Ubuntu Terminal
    $ source cookers/env.bash.imx7.terminal

    For IMX7 with Ubuntu XFCE Desktop
    $ source cookers/env.bash.imx7.xfce

Copy your compiled Linux Kernel moduels to fs_overlay folder (recommended):

    $ sudo cp -rv <target kernel folder>/modules/<specific kernel modules> cookers/fs_overlay/lib/modules/

Copy your custom excutable binary, configuration and libraries: to fs_overlay folder (recommended):

    $ sudo cp -rv <custom binary files> cookers/fs_overlay/usr/bin/
    $ sudo cp -rv <custom libraries files> cookers/fs_overlay/usr/lib/
    $ sudo cp -rv <custom configuration file> cookers/fs_overlay/etc/


Running Creator, need about one hour at the first time:

    $ gen_pure_rootfs
    (output file is a tarball named rootfs.tgz)

Replace your new Ubuntu rootfs to the target board:

Step 1. Format the partition of rootfs:

    $ sudo mkfs.ext4 /dev/sdx2
    NOTE: x is up to your device node

Step 2. Mount the partition of rootfs:

    $ sudo mount /dev/sdx2 mnt

Step 3. Extracting the Ubuntu rootfs tarball to the partition of rootfs:

    $ cd mnt
    $ sudo tar zxvf ../rootfs.tgz

Step 4. umount the partition and enjoy your Ubuntu OS:

    $ cd ..
    $ sudo umount mnt

Later chapters have detail description about what is the fs_overlay and how to make a highly customized rootfs.


## FS_OVERLAY
--------

fs_overlay is a folder holds custom configuration files, it has
the same folder structure as target rootfs, so if you have some specfic
setting or execute files, please take files to fs_overlay first, Ubuntu creator will copy to the target rootfs.

## How To Add New Packages at Default Configuration
--------

Please add new packages in cookers/tn_install.sh script if necessary:
Search "apt-get source update and installation" word and add packages such as

    # apt-get source update and installation
    sudo apt-get update
    yes "Y" | apt install openssh-server iw wpasupplicant hostapd util-linux procps iproute2 haveged dnsmasq iptables net-tools bluez ppp ntp ntpdate bridge-utils
    yes "Y" | apt install bash-completion
    + yes "Y" | apt install <your packages>

## How To Change the Ubuntu Revision
--------

Some users could be have other Ubuntu revision requirement, please modify gen_pure_rootfs API of cookers/env.bash script as following:

    - sudo debootstrap --arch=armhf --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign bionic ${TOP}/rootfs
    modify to Ubuntu 16.04 Xenial
    + sudo debootstrap --arch=armhf --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign xenial ${TOP}/rootfs

NOTE: The users also can change any revision using above method, just replace the release name is enough.

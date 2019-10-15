#!/bin/bash

MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
UBUNTU_TYPE=$(echo $MODULE | awk -F. '{print $4}')
TOP=${PWD}


# generate minimum rootfs
gen_pure_rootfs() {
  cp -rv cookers/tn_install.sh ${TOP}
  sudo debootstrap --arch=armhf --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign bionic ${TOP}/rootfs
  sudo cp /usr/bin/qemu-arm-static ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage
  sudo cp ${TOP}/tn_install.sh ${TOP}/rootfs/usr/bin/
  sudo cp ${TOP}/apt_list ${TOP}/rootfs/usr/bin/


  sudo cp -rv cookers/fs_overlay/etc/systemd/system/tn_init.service ${TOP}/rootfs/etc/systemd/system/

  if [[ "${UBUNTU_TYPE}" == "xfce" ]];then
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/tn_install.sh; /usr/bin/tn_install.sh gui"
  else
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/tn_install.sh; /usr/bin/tn_install.sh"
  fi

  # fs-overlay
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/bin/* ${TOP}/rootfs/usr/bin/
  sudo cp -rv ${TOP}/cookers/fs_overlay/lib/modules/ ${TOP}/rootfs/lib/
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/lib/arm-linux-gnueabihf/* ${TOP}/rootfs/usr/lib/arm-linux-gnueabihf/
  sudo rm -rf ${TOP}/rootfs/usr/lib/xorg/
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/lib/xorg/ ${TOP}/rootfs/usr/lib/
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/lib/dri ${TOP}/rootfs/usr/lib/
  sudo cp -rv ${TOP}/cookers/fs_overlay/etc/X11/xorg.conf ${TOP}/rootfs/etc/X11/
  sudo cp -rv ${TOP}/cookers/fs_overlay/etc/OpenCL ${TOP}/rootfs/etc/
  sudo cp -rv ${TOP}/cookers/fs_overlay/etc/alternatives/arm-linux-gnueabihf_* ${TOP}/rootfs/etc/alternatives/
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/include/* ${TOP}/rootfs/usr/include/
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/share/* ${TOP}/rootfs/usr/share/
  sudo cp -rv ${TOP}/cookers/fs_overlay/lib/firmware/ ${TOP}/rootfs/lib/
  cp -rv ${TOP}/cookers/fs_overlay/home/ubuntu/.* ${TOP}/rootfs/home/ubuntu/

  sync

  sudo rm -rf ${TOP}/rootfs/usr/bin/tn_install.sh

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
  rm -rf ${TOP}/tn_install.sh
}

merge_tn_fs_overlay() {
  wget -c -t 0 --timeout=60 --waitretry=60 https://github.com/technexion-android/android_restricted_extra/raw/master/imx6_7-bionic.tar.gz
  tar zxvf imx6_7-bionic.tar.gz
  mv ${TOP}/fs_overlay ${TOP}/cookers/
  rm -rf ${TOP}/imx6_7-bionic.tar.gz
  rm -rf ${TOP}/fs_overlay
}

throw_rootfs() {
  sudo swapoff ${TOP}/rootfs/swapfile
  sudo rm -rf ${TOP}/rootfs/
  sudo rm rootfs.tgz
}

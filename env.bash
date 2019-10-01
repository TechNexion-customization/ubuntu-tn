MODULE=$(basename $BASH_SOURCE)
CPU_TYPE=$(echo $MODULE | awk -F. '{print $3}')
UBUNTU_TYPE=$(echo $MODULE | awk -F. '{print $4}')






# generate minimum rootfs
gen_pure_rootfs() {
  TOP=${PWD}
  cp -rv cookers/tn_install.sh ${TOP}
  sudo debootstrap --arch=armhf --keyring=/usr/share/keyrings/ubuntu-archive-keyring.gpg --verbose --foreign bionic ${TOP}/rootfs
  sudo cp /usr/bin/qemu-arm-static ${TOP}/rootfs/usr/bin
  sudo LANG=C chroot ${TOP}/rootfs /debootstrap/debootstrap --second-stage
  sudo cp ${TOP}/tn_install.sh ${TOP}/rootfs/usr/bin/

  if [[ "${UBUNTU_TYPE}" == "xfce" ]];then
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/tn_install.sh; /usr/bin/tn_install.sh gui"
  else
    sudo LANG=C chroot ${TOP}/rootfs /bin/bash -c "chmod a+x /usr/bin/tn_install.sh; /usr/bin/tn_install.sh"
  fi

  # fs-overlay
  sudo cp -rv ${TOP}/cookers/fs_overlay/usr/bin/* ${TOP}/rootfs/usr/bin/
  sudo cp -rv ${TOP}/cookers/fs_overlay/lib/modules/ ${TOP}/rootfs/lib/
  for entry in $(ls ${TOP}/cookers/fs_overlay/usr/bin/); do
    echo $entry
  done


  sudo rm -rf ${TOP}/rootfs/usr/bin/tn_install.sh

  cd ${TOP}/rootfs
  sudo tar --exclude='./dev/*' --exclude='./lost+found' --exclude='./mnt/*' --exclude='./media/*' --exclude='./proc/*' --exclude='./run/*' --exclude='./sys/*' --exclude='./tmp/*' --numeric-owner -czpvf ../rootfs.tgz .
  cd ${TOP}
  rm -rf ${TOP}/tn_install.sh
}

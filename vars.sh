#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

TMPIMAGEDL=/tmp/raspbian_lite.img.zip
IMAGE="raspbian_lite.img"
MOUNT_POINT="root_mount"
# QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 console=ttyAMA0 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw' -sd ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
if [ -z ${DISPLAY:-} ] ; then
    QEMU_OPTS+=(-nographic)
fi
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

QEMU_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.13-jessie"
QEMU_KERNEL=kernel-qemu

wget ${QEMU_KERNEL_URL} -O ${QEMU_KERNEL}

# QEMU system
QEMU=qemu-system-arm
# QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 console=ttyAMA0 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
QEMU_OPTS="-kernel ${QEMU_KERNEL} -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -drive file=${IMAGE_DEST},format=raw -append 'root=/dev/mmcblk0p2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw' -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic"
if [ -z ${DISPLAY:-} ] ; then
    QEMU_OPTS+=" -nographic -monitor none"
fi
echo ${QEMU} ${QEMU_OPTS}
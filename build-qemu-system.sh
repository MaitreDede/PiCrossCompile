#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

QEMU_KERNEL_URL="https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.13-jessie"
QEMU_KERNEL=kernel-qemu

if [ ! -f ${QEMU_KERNEL} ]
then
    wget ${QEMU_KERNEL_URL} -O ${QEMU_KERNEL}
fi

# QEMU system
QEMU=qemu-system-arm
QEMU_CPU=arm1176
QEMU_MACHINE=versatilepb
# QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 console=ttyAMA0 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
# QEMU_OPTS=(-kernel ${QEMU_KERNEL} -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -drive file=${IMAGE_DEST},format=raw -append "root=/dev/sda2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw" -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
# QEMU_OPTS=" -kernel ${QEMU_KERNEL}"
# QEMU_OPTS+=" -cpu arm1176"
# QEMU_OPTS+=" -m 256"
# QEMU_OPTS+=" -M versatilepb"
# QEMU_OPTS+=" -no-reboot"
# QEMU_OPTS+=" -serial stdio"
# QEMU_OPTS+=" -drive file=${IMAGE_DEST},format=raw"
# QEMU_OPTS+=" -append 'root=/dev/sda2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw'"
# QEMU_OPTS+=" -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069"
# QEMU_OPTS+=" -net nic"

# if [ -z ${DISPLAY:-} ] ; then
    QEMU_OPTS+=" -nographic -monitor none"
# fi
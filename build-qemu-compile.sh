#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# QEMU BUILD
QEMU_URL=https://download.qemu.org/qemu-2.10.1.tar.xz
QEMU_TMP=/tmp/qemu.tar.xz
QEMU_OUT=${HOME}/qemu

CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)

wget ${QEMU_URL} -O ${QEMU_TMP}

mkdir -p ${QEMU_OUT}
pushd ${QEMU_OUT}
tar xJf ${QEMU_TMP} --strip-components=1 --overwrite
rm ${QEMU_TMP}

./configure --target-list=arm-softmmu,arm-linux-user,armeb-linux-user > build-qemu.log
echo Compiling with ${CPU_COUNT} CPU
make -j${CPU_COUNT} >> build-qemu.log
popd

QEMU=${QEMU_OUT}/arm-softmmu/qemu-system-arm

# QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/mmcblk0p2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw' -drive file=${IMAGE},format=raw -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
QEMU_OPTS=(-kernel kernel-qemu -m 256 -M raspi2 -no-reboot -serial stdio -append 'root=/dev/mmcblk0p2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw' -drive file=${IMAGE},format=raw -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)
if [ -z ${DISPLAY:-} ] ; then
    QEMU_OPTS+=(-nographic -monitor none)
fi
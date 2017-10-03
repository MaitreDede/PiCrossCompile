#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

QEMU_URL=https://download.qemu.org/qemu-2.10.1.tar.xz
QEMU_TMP=/tmp/qemu.tar.xz
QEMU_OUT=${HOME}/qemu

CPU_COUNT=$(grep -c ^processor /proc/cpuinfo)

wget ${QEMU_URL} -O ${QEMU_TMP}

mkdir -p ${QEMU_OUT}
pushd ${QEMU_OUT}
tar xJf ${QEMU_TMP} --strip-components=1 --overwrite
rm ${QEMU_TMP}

./configure --target-list=arm-softmmu,arm-linux-user,armeb-linux-user
echo Compiling with ${CPU_COUNT} CPU
make -j${CPU_COUNT}
popd

ln -s ${QEMU_OUT}/arm-softmmu/qemu-system-arm ${HOME}/qemu-bin

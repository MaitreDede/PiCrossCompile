#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

QEMU_URL=https://download.qemu.org/qemu-2.10.1.tar.xz
QEMU_TMP=/tmp/qemu.tar.xz
QEMU_OUT=${HOME}/qemu

wget ${QEMU_URL} -O ${QEMU_TMP}

mkdir -p ${QEMU_OUT}
pushd ${QEMU_OUT}
tar xJf ${QEMU_TMP} --strip-components=1 --overwrite
rm ${QEMU_TMP}

./configure
make -j`grep -c ^processor /proc/cpuinfo`
popd

export QEMU=${QEMU_OUT}/arm-softmmu/qemu-system-arm

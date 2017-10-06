#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [ -d ${QEMU_KERNEL} ]
then
    rm -Rf ${QEMU_KERNEL}
fi
if [ ! -f ${QEMU_KERNEL} ]
then
    wget ${QEMU_KERNEL_URL} -O ${QEMU_KERNEL}
fi
if [ -d ${IMAGE_PRISTINE} ]
then
    rm -Rf ${IMAGE_PRISTINE}
fi
if [ ! -f ${IMAGE_PRISTINE} ]
then
    wget ${IMAGE_SOURCE} -O ${IMAGE_TMP}
    unzip -p ${IMAGE_TMP} `unzip -Z1 ${IMAGE_TMP}` > ${IMAGE_PRISTINE}
    rm ${IMAGE_TMP}
fi
#!/usr/bin/env bash

if [ -z ${QEMU_VERSION:-} ]
then
    QEMU_VERSION=
fi

if [ "${QEMU_VERSION}" = "COMPILED" ]
then
    echo "Compiling latest qemu"
    source build-qemu-compile.sh
else
    if [ "${QEMU_VERSION}" = "SYSTEM" ]
    then
        echo "Using system qemu"
        source build-qemu-system.sh
    else
        echo "WARNING : unspecified or invalid value for QEMU_VERSION. Valid values are COMPILED,SYSTEM. Found '${QEMU_VERSION}'"
        echo "Assuming default: SYSTEM"
        source build-qemu-system.sh
    fi
fi
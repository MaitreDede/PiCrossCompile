#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

case ${QEMU_VERSION} in
"COMPILED")
    echo "Compiling latest qemu"
    source build-qemu-compile.sh
    ;;
"SYSTEM")
    echo "Using system qemu"
    source build-qemu-system.sh
    ;;
*)
    echo "WARNING : unspecified or invalid value for QEMU_VERSION. Valid values are COMPILED,SYSTEM. Found '${QEMU_VERSION}'"
    echo "Assuming default: SYSTEM"
    source build-qemu-system.sh
    ;;
esac
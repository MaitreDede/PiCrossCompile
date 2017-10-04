#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# if [[ $EUID -ne 0 ]]; then
#    echo "This script must be run as root" 
#    exit 1
# fi

if cat /proc/mounts | grep ${MOUNT_POINT};
then
    sudo umount "${MOUNT_POINT}"
fi
if sudo kpartx -ls ${IMAGE_DEST} | grep loop;
then
    sudo kpartx -dvs ${IMAGE_DEST}
fi
if [ -f ${IMAGE_TMPDL} ];
then
    rm ${IMAGE_TMPDL}
fi
if [ -f ${QEMU_KERNEL} ]
then
    rm ${QEMU_KERNEL}
fi
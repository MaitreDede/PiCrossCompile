#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

wget ${IMAGE_SOURCE} -O ${IMAGE_TMPDL}
IMAGEFILE=`unzip -Z1 ${IMAGE_TMPDL}`
echo Decompressing image ${IMAGEFILE} to ${IMAGE_DEST}
unzip -p ${IMAGE_TMPDL} ${IMAGEFILE} > ${IMAGE_DEST}
rm ${IMAGE_TMPDL}
echo "Enlarging your image"
dd if=/dev/zero bs=1M count=2048 >> ${IMAGE_DEST}
./fdisk.sh ${IMAGE_DEST}

LOOP_MAPPER_PATH=$(kpartx -avs ${IMAGE_DEST} | tail -n 1 | cut -d ' ' -f 3)
LOOP_MAPPER_PATH=/dev/mapper/${LOOP_MAPPER_PATH}
echo LOOP_MAPPER_PATH=${LOOP_MAPPER_PATH}
sleep 5
e2fsck -f "${LOOP_MAPPER_PATH}"
resize2fs "${LOOP_MAPPER_PATH}"
mkdir -p "${MOUNT_POINT}"

mount_image() {
    mount "${LOOP_MAPPER_PATH}" "${MOUNT_POINT}"
    sleep 2
}

unmount_image() {
    sync
    umount "${MOUNT_POINT}"
}
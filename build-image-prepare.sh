#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo Copying pristine ${IMAGE_PRISTINE} to ${IMAGE_DEST}
cp ${IMAGE_PRISTINE} ${IMAGE_DEST}

echo "Enlarging your image..."
dd if=/dev/zero bs=1M count=2048 >> ${IMAGE_DEST}
echo "Fdisking..."
START_OF_ROOT_PARTITION=$(fdisk -l ${IMAGE_DEST} | tail -n 1 | awk '{print $2}')
(echo 'p';                          # print
 echo 'd';                          # delete
 echo '2';                          #   second partition
 echo 'n';                          # create new partition
 echo 'p';                          #   primary
 echo '2';                          #   number 2
 echo "${START_OF_ROOT_PARTITION}"; #   starting at previous offset
 echo '';                           #   ending at default (fdisk should propose max)
 echo 'p';                          # print
 echo 'w') | fdisk ${IMAGE_DEST}       # write and quit

LOOP_MAPPER_PATH=$(kpartx -avs ${IMAGE_DEST} | tail -n 1 | cut -d ' ' -f 3)
LOOP_MAPPER_PATH=/dev/mapper/${LOOP_MAPPER_PATH}
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
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

wget ${IMAGE_SOURCE} -O ${IMAGE_TMPDL}
IMAGEFILE=`unzip -Z1 ${IMAGE_TMPDL}`
echo Decompressing image ${IMAGEFILE} to ${IMAGE_DEST}
unzip -p ${IMAGE_TMPDL} ${IMAGEFILE} > ${IMAGE_DEST}
rm ${IMAGE_TMPDL}
echo "Enlarging your image"
dd if=/dev/zero bs=1M count=2048 >> ${IMAGE_DEST}
echo "Fdisking ${IMAGE_DEST}"
START_OF_ROOT_PARTITION=$(sudo fdisk -l ${IMAGE_DEST} | tail -n 1 | awk '{print $2}')
(echo 'p';                          # print
 echo 'd';                          # delete
 echo '2';                          #   second partition
 echo 'n';                          # create new partition
 echo 'p';                          #   primary
 echo '2';                          #   number 2
 echo "${START_OF_ROOT_PARTITION}"; #   starting at previous offset
 echo '';                           #   ending at default (fdisk should propose max)
 echo 'p';                          # print
 echo 'w') | sudo fdisk ${IMAGE_DEST}       # write and quit

LOOP_MAPPER_PATH=$(sudo kpartx -avs ${IMAGE_DEST} | tail -n 1 | cut -d ' ' -f 3)
LOOP_MAPPER_PATH=/dev/mapper/${LOOP_MAPPER_PATH}
sleep 5
sudo e2fsck -f "${LOOP_MAPPER_PATH}"
sudo resize2fs "${LOOP_MAPPER_PATH}"
mkdir -p "${MOUNT_POINT}"

mount_image() {
    sudo mount "${LOOP_MAPPER_PATH}" "${MOUNT_POINT}"
    sleep 2
}

unmount_image() {
    sudo sync
    sudo umount "${MOUNT_POINT}"
}
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source vars.sh

require_command kpartx
require_command qemu-system-arm
require_command zerofree


#Raspbian image
wget 'https://downloads.raspberrypi.org/raspbian_lite_latest' -O ${TMPIMAGEDL}
IMAGEFILE=`unzip -Z1 ${TMPIMAGEDL}`
echo Decompressing image ${IMAGEFILE} to ${IMAGE}
unzip -p ${TMPIMAGEDL} ${IMAGEFILE} > ${IMAGE}
rm ${TMPIMAGEDL}
echo "Enlarging your image"
dd if=/dev/zero bs=1M count=2048 >> ${IMAGE}
./fdisk.sh ${IMAGE}

LOOP_MAPPER_PATH=$(kpartx -avs ${IMAGE} | tail -n 1 | cut -d ' ' -f 3)
LOOP_MAPPER_PATH=/dev/mapper/${LOOP_MAPPER_PATH}
echo LOOP_MAPPER_PATH=${LOOP_MAPPER_PATH}
sleep 5
e2fsck -f "${LOOP_MAPPER_PATH}"
resize2fs "${LOOP_MAPPER_PATH}"
mkdir -p "${MOUNT_POINT}"
mount "${LOOP_MAPPER_PATH}" "${MOUNT_POINT}"
sleep 2
echo "Copying files"
mv ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/rc.local.backup
mv ${MOUNT_POINT}/etc/ld.so.preload ${MOUNT_POINT}/etc/ld.so.preload.backup
touch ${MOUNT_POINT}/etc/ld.so.preload
cp --recursive --verbose pi-stage0/* "${MOUNT_POINT}"
sync
umount "${MOUNT_POINT}"

#Emulation
wget 'https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.13-jessie' -O kernel-qemu
${QEMU} "${QEMU_OPTS[@]}"
echo "Qemu ended"

#cleanup
echo "Restoring files"
mount "${LOOP_MAPPER_PATH}" "${MOUNT_POINT}"
sleep 2
rm ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/ld.so.preload
mv ${MOUNT_POINT}/etc/rc.local.backup ${MOUNT_POINT}/etc/rc.local
mv ${MOUNT_POINT}/etc/ld.so.preload.backup ${MOUNT_POINT}/etc/ld.so.preload

cp ${MOUNT_POINT}/home/pi/build-image.log .
sync
source cleanup.sh

echo Your image is ready.
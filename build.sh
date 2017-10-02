#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

TMPIMAGEDL=/tmp/raspbian_lite.img.zip
#IMAGE="${HOME}/raspbian_lite.img"
IMAGE="raspbian_lite.img"
#MOUNT_POINT="${HOME}/root_mount"
MOUNT_POINT="root_mount"
#QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic -nographic)
#QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic -curses)
QEMU_OPTS=(-kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append 'root=/dev/sda2 rootfstype=ext4 rw' -hda ${IMAGE} -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic)

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
# cp -a pi-stage0 "${MOUNT_POINT}"
# umount "${MOUNT_POINT}"

# #Emulation
# wget 'https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.13-jessie' -O kernel-qemu
# qemu-system-arm "${QEMU_OPTS[@]}"
# echo Qemu ended
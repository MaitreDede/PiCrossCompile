#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

require_command () {
    type "$1" &> /dev/null || { echo "Command $1 is missing. Install it e.g. with 'apt-get install $1'. Aborting." >&2; exit 1; }
}

IMAGE_SOURCE="https://downloads.raspberrypi.org/raspbian_lite_latest"
IMAGE_TMPDL=/tmp/raspbian_lite.img.zip
IMAGE_DEST="raspbian_lite.img"
MOUNT_POINT="root_mount"

echo ================================================
echo == Preparing emulation with qemu
echo -en 'travis_fold:start:script.prepare_qemu\\r'
source build-qemu.sh
echo QEMU=${QEMU}
echo QEMU_OPTS=${QEMU_OPTS}
require_command ${QEMU}
echo -en 'travis_fold:end:script.prepare_qemu\\r'

echo ================================================
echo == Preparing raspbian image
echo -en 'travis_fold:start:script.prepare_image\\r'
require_command kpartx
require_command zerofree
source build-image-prepare.sh
echo -en 'travis_fold:end:script.prepare_image\\r'

#Raspbian image
echo ================================================
echo == Building image : backup of some original files
mount_image
mv ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/rc.local.backup
mv ${MOUNT_POINT}/etc/ld.so.preload ${MOUNT_POINT}/etc/ld.so.preload.backup
touch ${MOUNT_POINT}/etc/ld.so.preload
chmod +x ${MOUNT_POINT}/etc/ld.so.preload
unmount_image

# cp --recursiœe --verbose pi-stage0/* "${MOUNT_POINT}"
# sync
# umount "${MOUNT_POINT}"

# #Emulation
# echo "Qemu options: ${QEMU_OPTS[@]}"
#  "${QEMU_OPTS[@]}"
# echo "Qemu ended"

# #cleanup
# echo "Restoring files"
# mount "${LOOP_MAPPER_PATH}" "${MOUNT_POINT}"
# sleep 2
# rm ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/ld.so.preload
# mv ${MOUNT_POINT}/etc/rc.local.backup ${MOUNT_POINT}/etc/rc.local
# mv ${MOUNT_POINT}/etc/ld.so.preload.backup ${MOUNT_POINT}/etc/ld.so.preload

# cp ${MOUNT_POINT}/home/pi/build-image.log .
# sync
# source cleanup.sh

# echo Your image is ready.
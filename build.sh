#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# require_command () {
#     type "$1" &> /dev/null || { echo "Command $1 is missing. Install it e.g. with 'apt-get install $1'. Aborting." >&2; exit 1; }
# }

IMAGE_SOURCE="https://downloads.raspberrypi.org/raspbian_lite_latest"
IMAGE_TMPDL=/tmp/raspbian_lite.img.zip
IMAGE_DEST="raspbian_lite.img"
MOUNT_POINT="root_mount"

echo ================================================
echo == Preparing raspbian image
echo -en 'travis_fold:start:script.prepare_image\\r\\n'
source build-image-prepare.sh
echo -en 'travis_fold:end:script.prepare_image\\r\\n'

echo ================================================
echo == Preparing emulation with qemu
echo -en 'travis_fold:start:script.prepare_qemu\\r\\n'
source build-qemu.sh
echo -en 'travis_fold:end:script.prepare_qemu\\r\\n'

echo ================================================
echo == Building image : backup of some original files
mount_image
mv ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/rc.local.backup
mv ${MOUNT_POINT}/etc/ld.so.preload ${MOUNT_POINT}/etc/ld.so.preload.backup
touch ${MOUNT_POINT}/etc/ld.so.preload
chmod +x ${MOUNT_POINT}/etc/ld.so.preload
unmount_image

echo ================================================
echo == Building image : stage 0 - copying files
mount_image
cp --recursive --verbose pi-stage0/* "${MOUNT_POINT}"

echo ----
ls -l ${MOUNT_POINT}/etc/build*
echo ----

unmount_image

echo ================================================
echo == Building image : stage 0 - simulate once
if [ -z ${DISPLAY:-} ]
then
    QEMU_OPTS=" -nographic -monitor none"
else
    QEMU_OPTS=""
fi
set -x
${QEMU} -kernel ${QEMU_KERNEL} -cpu ${QEMU_CPU} -m 256 -M ${QEMU_MACHINE} -no-reboot -serial stdio -drive file=${IMAGE_DEST},format=raw -append 'root=/dev/sda2 earlyprintk rootfstype=ext4 console=ttyAMA0 rw' -net user,hostfwd=tcp::10022-:22,hostfwd=tcp::18069-:8069 -net nic ${QEMU_OPTS}
set +x

echo ================================================
echo == Building image : restoring original files
mount_image
rm ${MOUNT_POINT}/etc/rc.local ${MOUNT_POINT}/etc/ld.so.preload
mv ${MOUNT_POINT}/etc/rc.local.backup ${MOUNT_POINT}/etc/rc.local
mv ${MOUNT_POINT}/etc/ld.so.preload.backup ${MOUNT_POINT}/etc/ld.so.preload
unmount_image

source cleanup.sh

echo ================================================
echo Done.
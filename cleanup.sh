#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

source vars.sh

if cat /proc/mounts | grep ${MOUNT_POINT};
then
    umount "${MOUNT_POINT}"
fi
if kpartx -ls ${IMAGE} | grep loop;
then
    kpartx -dvs ${IMAGE}
fi
if [ -f ${TMPIMAGEDL} ];
then
    rm ${TMPIMAGEDL}
fi
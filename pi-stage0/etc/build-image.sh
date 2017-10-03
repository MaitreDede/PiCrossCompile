#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

###################################
## functions from raspi-config
CONFIG=/boot/config.txt
set_config_var() {
  lua - "$1" "$2" "$3" <<EOF > "$3.bak"
local key=assert(arg[1])
local value=assert(arg[2])
local fn=assert(arg[3])
local file=assert(io.open(fn))
local made_change=false
for line in file:lines() do
  if line:match("^#?%s*"..key.."=.*$") then
    line=key.."="..value
    made_change=true
  end
  print(line)
end
if not made_change then
  print(key.."="..value)
end
EOF
mv "$3.bak" "$3"
}
###################################

# Since we are emulating, the real /boot is not mounted, 
# leading to mismatch between kernel image and modules.
UNMOUNTBOOT=0
if cat /proc/mounts | grep /dev/sda1
then
    echo /boot already mounted.
else
    echo mounting /boot
    mount /dev/sda1 /boot
    UNMOUNTBOOT=1
fi


# Recommends: antiword, graphviz, ghostscript, postgresql, python-gevent, poppler-utils
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y dist-upgrade

#build tools
apt-get install -y git build-essential rsync jq pigpio \
    curl libunwind8 gettext

#dotnet core 2.0
# apt-get install -y curl libunwind8 gettext
# curl -sSL -o /tmp/dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Runtime/release/2.0.0/dotnet-runtime-latest-linux-arm.tar.gz
# mkdir -p /opt/dotnet 
# tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
# ln -s /opt/dotnet/dotnet /usr/local/bin

# cleanup
apt-get clean

#Raspberry pi configuration
PICONF=/etc/build-image.json
DO_REBOOT=1
if [ -f $PICONF ]
then
    echo "Configuring the pi..."
    GPU_MEM=$(jq ".gpu_mem" $PICONF)
    SERIAL=$(jq ".do_serial" $PICONF)
    PASSWD=$(jq ".passwd" $PICONF)
    DO_REBOOT$(jq ".reboot" $PICONF)

    # raspi-config nonint do_memory_split 256
    set_config_var gpu_mem $GPU_MEM $CONFIG
    raspi-config nonint do_serial 1

    (echo "raspberry"; echo $PASSWD; echo $PASSWD) | passwd pi
fi

#services
systemctl daemon-reload
systemctl enable ssh

# done
if [ "$UNMOUNTBOOT" = "1" ]
then
    echo Unmounting /boot
    umount /dev/sda1
else
    echo No need to unmount /boot
fi

if [ "$DO_REBOOT" = "0" ]
then
    echo "Not rebooting..."
else
    reboot
fi
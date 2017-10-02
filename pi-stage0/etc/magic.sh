#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

# Since we are emulating, the real /boot is not mounted, 
# leading to mismatch between kernel image and modules.
mount /dev/sda1 /boot

# Recommends: antiword, graphviz, ghostscript, postgresql, python-gevent, poppler-utils
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y dist-upgrade

#build tools
apt-get install -y git build-essential

#gpio
apt-get install -y pigpio

#dotnet core 2.0
apt-get install -y curl libunwind8 gettext
# curl -sSL -o /tmp/dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Runtime/release/2.0.0/dotnet-runtime-latest-linux-arm.tar.gz
# mkdir -p /opt/dotnet 
# tar zxf /tmp/dotnet.tar.gz -C /opt/dotnet
# ln -s /opt/dotnet/dotnet /usr/local/bin

# cleanup
apt-get clean

#Raspberry pi configuration
raspi-config nonint do_memory_split 256
raspi-config nonint do_serial 1

#services
systemctl daemon-reload
systemctl enable ssh

# done
umount /dev/sda1
reboot
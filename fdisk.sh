#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail

echo "Fdisking $1"
START_OF_ROOT_PARTITION=$(fdisk -l $1 | tail -n 1 | awk '{print $2}')
(echo 'p';                          # print
 echo 'd';                          # delete
 echo '2';                          #   second partition
 echo 'n';                          # create new partition
 echo 'p';                          #   primary
 echo '2';                          #   number 2
 echo "${START_OF_ROOT_PARTITION}"; #   starting at previous offset
 echo '';                           #   ending at default (fdisk should propose max)
 echo 'p';                          # print
 echo 'w') | fdisk $1       # write and quit

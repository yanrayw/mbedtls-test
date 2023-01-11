#!/bin/sh
#
#  Copyright (c) 2017-2021, ARM Limited, All Rights Reserved
#  SPDX-License-Identifier: Apache-2.0
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may
#  not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file is part of Mbed TLS (https://www.trustedfirmware.org/projects/mbed-tls/)
#
# Purpose
#
# This is a helper script to start a docker container with common features.
# 
# Features:
#   User Ids    User/Grp Ids are specified same as the host user so that files
#               created/updated by docker image can be accessible after
#               exiting the image.
#   Mount dir   Mounts a user specified dir to the working dir in the image.
#   Mount ~/.ssh Also mounts host's ~/.ssh to ~/.ssh
#               in the image. So git can be used.
#
# Usage: ./run.sh mount_dir docker_image_tag
#
#   mount_dir           Directory to mount on the image as the working dir.
#   docker_image_tag    Docker image to run.
#

display_help() {
    # echo some stuff here as help information
    echo
    echo "   -h, --help			help function"
    echo "   $0: usage: $0 -m mount_dir -v docker_image_tag"
    echo "   Eg: $0 (-d) -m ~ -v 18"
    echo
    exit 1
}

#########################################################################
# Check if parameters options are given on the commandline
#########################################################################
while [ $# -ge 1 ]; do
    case "$1" in
      -h | --help)
          display_help  # Call your function
          exit 0
          ;;
      -d | --detach)
          detach="-d"  # run container in detach mode? 
	  shift 1
          ;;
      -m | --mount)
          mount_dir=$2  # the directory to mount
	  shift 2
          ;;
      -v | --system_version) # which ubuntu version to run
          ver=$2  #
	  shift 2
          ;;

      --) # End of all options
          shift
          break
          ;;
      -*)
          echo "Error: Unknown option: $1" >&2
          # or call function display_help
          exit 1
          ;;
      *)  # No more options
          break
          ;;
    esac
done

. $(dirname -- "$0")/include.sh
system_ver=$system-$ver$1.04
container_name="$container_name_prefix.$system_ver"

list_sh="$(dirname -- "$0")/list-docker-image-tags.sh"
image_tag=$("$list_sh" "$system_ver")

USR_NAME=`id -un`
USR_ID=`id -u`
USR_GRP=`id -g`
SSH_CFG_PATH=~/.ssh

echo "****************************************************"
echo "  Running docker image - $system_ver"
echo "  User ID:Group ID --> $USR_ID:$USR_GRP"
echo "  Mounting $SSH_CFG_PATH --> /home/user/.ssh"
echo "  Mounting $mount_dir --> /var/lib/ws"
echo "  Creating container --> $container_name"
echo "****************************************************"

sudo docker run --network=host --rm -i -t                       \
    $detach --name $container_name                              \
    -u $USR_ID:$USR_GRP -w /var/lib/ws                          \
    -v $mount_dir:/var/lib/ws -v $SSH_CFG_PATH:/home/user/.ssh  \
    --cap-add SYS_PTRACE $image_prefix${system_ver}:${image_tag}


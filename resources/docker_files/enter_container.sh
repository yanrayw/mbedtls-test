#!/bin/bash

#########################################################################
 # File Name: enter_container.sh
 # Author: Yanray Wang
 # e-mail: wangyanray47@gmail.com
 # Created Time: Fri 21 Oct 2022 02:29:08 PM CST
#########################################################################

display_help() {
    # echo some stuff here as help information
    echo
    echo "   -h, --help			help function"
    echo "   $0: usage: $0 ubuntu_version"
    echo "   Eg: $0 18"
    echo
    exit 1
}

#########################################################################
# Check if parameters options are given on the commandline 
#########################################################################
while :
do
    case "$1" in
      -h | --help)
          display_help  # Call your function
          exit 0
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

pre_init(){
    :
}

docker_run(){
    docker exec -it $1 bash
}

pre_init
docker_run $container_name


# !/bin/bash

trap 'last' {1,2,3,15}

function last(){
	echo "kill trap"
	exit 1
}
NAME=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'))
echo "${NAME[@]}"
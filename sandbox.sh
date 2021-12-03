# !/bin/bash

trap 'last' {1,2,3,15}

function last(){
	echo "kill trap"
	exit 1
}

sleep 5
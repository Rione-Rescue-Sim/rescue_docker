# !/bin/bash

NAME=$1

trap 'last' {1,2,3,15}

function last(){
	echo "kill trap"
	docker container stop ${NAME}
	exit 1
}

docker container exec \
	-it \
	${NAME} \
	bash rioneLauncher_2.2.2.sh 1

docker container stop ${NAME}
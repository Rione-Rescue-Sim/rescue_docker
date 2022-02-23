# !/bin/bash

# makefileからkillをトラップできないので、kill時にコンテナを停止させるために作成
CONTAINER_NAME=$1

ARG=$2

trap 'last' {1,2,3,15}

function last(){
	echo "kill trap"
	docker container stop ${CONTAINER_NAME}
	exit 1
}

if [[ ${ARG} == 'debug' ]]; then

	faketty docker container exec -it ${CONTAINER_NAME} bash rioneLauncher_2.2.2.sh ${ARG}

else

	docker container exec \
	-it \
	${CONTAINER_NAME} \
	bash rioneLauncher_2.2.2.sh ${ARG}


fi

docker container stop ${CONTAINER_NAME}
# !/bin/bash

# レスキューのソースコードを探索し、コンテナ内にコピーする
# makefileで配列やifを書くのは面倒なのでシェルスクリプトに記述

CONTAINER_NAME=$1
DOCKER_HOME_DIR=$2

if [[ -z ${CONTAINER_NAME} || -z ${DOCKER_HOME_DIR} ]]; then

	echo
    echo "[ERROR] $LINENO"
    echo "引数が指定されていません"
    echo
    exit 1

fi

rescue_code_path=($(find ~/ -maxdepth 4 -type d -name ".*" -prune -o -type f -print | grep config/module.cfg | sed 's@/config/module.cfg@@g'))

if [[ ${#rescue_code_path[@]} -gt 0 ]]; then

	for item in "${rescue_code_path[@]}" ; do

		docker container cp ${item} ${CONTAINER_NAME}:${DOCKER_HOME_DIR}

	done

else

    echo
    echo "[ERROR] $LINENO"
    echo "レスキューのソースコードを発見できませんでした"
    echo

fi
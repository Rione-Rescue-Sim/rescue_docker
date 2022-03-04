NAME := rescue_d
TS := `date +%Y%m%d%H%M%S`
SCORE_FILE := score.csv
DOCKER_USER_NAME := RDocker
DOCKER_HOME_DIR := /home/${DOCKER_USER_NAME}
CURRENT_PATH := $(shell pwd)
RescueSRC := RIORescue

help:
	@echo "----------------------------------"
	@echo "レスキュー実行手順"
	@echo "コマンド実行時にレスキューのソースコードを探索して同期するので、"
	@echo "手動で同期を取る必要はありません"
	@echo "1. make build"
	@echo "2. make rioneLauncher"
	@echo "----------------------------------"
	@echo "##注意##"
	@echo "コンテナ内のデータはレスキューのスコアのみ保存されます。"
	@echo "それ以外のデータはコンテナ終了時にすべて破棄されます。"
	@echo "コンテナ内での開発はコンテナ終了時に破棄されるので避けてください。"
	@echo "新しいパッケージを導入する場合はDocker fileを編集してください。"
	@echo "----------------------------------"
	@echo "コマンド一覧"
	@echo "make build\tコンテナをビルド"
	@echo "\t\tパッケージやサーバの更新などをする"
	@echo "\t\tapt updateと同じ感じです"
	@echo "\t\t基本はこちらを利用"
	@echo ""
	@echo "make rebuild\tubuntu含むすべてをゼロからビルド"
	@echo "\t\t時間がかかります"
	@echo "\t\t何か不具合があった場合は実行"
	@echo ""
	@echo "make run\tコンテナを起動"
	@echo "\t\t ソースコードを同期してからコンテナ起動"
	@echo ""
	@echo "make rioneLauncher\tレスキューを実行"
	@echo "\t\t make run -> bash rioneLauncher 1を省略できる"
	@echo ""
	# @echo "make sync\tホストのソースコード(${RescueSRC})をコンテナ内に同期"
	# @echo "\t\t コンテナ起動中にソースコードを同期する際に利用"
	# @echo ""
	@echo "make clean\tコンテナとイメージを削除"
	@echo "\t\t命令はdocker system pluneなので他のDockerイメージも消えます"
	@echo ""
	@echo "make connect\t起動中のコンテナにroot権限で接続"
	@echo "\t\t使用例: 新しいパッケージの導入テストなど"
	@echo ""
	@echo "make update\tアップデート"
	@echo "\t\t最新のDockerFileでビルドする"
	@echo "\t\tgit pull & make build"
	@echo ""
	@echo "make install\tDockerの環境構築"
	@echo "\t\t主にDocker環境の構築＆sudo無しでのDockerコマンド実行の設定"
	@echo "----------------------------------"

# キャッシュ有りでビルド
build:
	docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} .

# コンテナ実行
run:
	xhost local:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	bash dockerCp.sh ${NAME} ${DOCKER_HOME_DIR}
	- docker container exec -it ${NAME} bash
	docker container stop ${NAME}


rioneLauncher:
	xhost local:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	- bash dockerCp.sh ${NAME} ${DOCKER_HOME_DIR}
	bash execRioneLauncherInDocker.sh ${NAME} 1


# dockerのリソースを開放
clean:
	docker system prune -y

# キャッシュを使わずにビルド
rebuild:
	@echo "コンテナの再構築には時間がかかります"
	@echo "コンテナを再構築しますか？ (y/n)"
	@read -p "->" ans;\
	if [ "$$ans" != y ]; then  \
      exit 1;\
    fi
	docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} \
	--pull \
	--no-cache=true .

# root権限で起動中のコンテナに接続
connect:
	docker exec -u root -it ${NAME} /bin/bash

# sync:
# 	bash rescue2docker.sh
# ifeq ($(shell docker container ls | grep "rescue_d:latest"),)
# 	@echo "コンテナが起動していません"
# 	exit 1
# endif
# 	docker cp ${RescueSRC}/ ${NAME}:/${DOCKER_USER_NAME}/

update:
	git pull
	make build

# 環境構築
install:
	sudo apt update
	sudo apt install -y apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	sudo apt update
	apt-cache policy docker-ce
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
ifneq ($(shell getent group docker| cut -f 4 --delim=":"),$(shell whoami))
	sudo gpasswd -a $(shell whoami) docker
endif
	sudo chgrp docker /var/run/docker.sock
	sudo systemctl restart docker
	@echo "環境構築を完了するために再起動してください"

# デバッグ用
test:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	bash dockerCp.sh ${NAME} ${DOCKER_HOME_DIR}
	docker cp makefile ${NAME}:${DOCKER_HOME_DIR}/RioneLauncher/makefile
	docker container exec -it ${NAME} make testInContainer
	bash execRioneLauncherInDocker.sh ${NAME} debug

testInContainer:
	sed -i -e 's/kernel.timesteps: 300/kernel.timesteps: 10/' ~/rcrs-server-1.5/maps/gml/test/config/kernel.cfg
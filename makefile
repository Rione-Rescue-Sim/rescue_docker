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
	@echo "\t\t主にDocker環境の構築&sudo無しでのDockerコマンド実行の設定"
	@echo "----------------------------------"

# キャッシュ有りでビルド
build:
	DOCKER_BUILDKIT=1 docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} \
	--force-rm=true .
	- docker rmi $(shell docker images -f 'dangling=true' -q)

# コンテナ内でbashを実行
# 対話的な動作をする場合に使用
run:
	make pre-exec_ --no-print-directory
	- docker container exec -it ${NAME} bash
	make post-exec_ --no-print-directory


# ランチャーの実行
# make run → bash rioneLauncherと打つのが手間なので作成
rioneLauncher:
	make pre-exec_ --no-print-directory
	- docker container exec -it ${NAME} bash rioneLauncher_2.2.2.sh 1
	make post-exec_ --no-print-directory

# 起動前処理
# コンテナの起動とファイルのコピーを行う
pre-exec_:
ifneq ($(shell docker ps -a | grep ${NAME}),) #起動済みのコンテナを停止
	docker container stop ${NAME}
endif
	xhost +local:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=:0.0 \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	bash dockerCp.sh ${NAME} ${DOCKER_HOME_DIR}
	- docker cp ~/.bashrc ${NAME}:${DOCKER_HOME_DIR}/.bashrc

# コンテナ終了時の処理
# ログをローカルへコピーする
post-exec_:
	- docker container cp ${NAME}:${DOCKER_HOME_DIR}/RioneLauncher/agent.log ./agent.log
	- docker container cp ${NAME}:${DOCKER_HOME_DIR}/RioneLauncher/server.log ./server.log
	docker container stop ${NAME}


# デバッグ用
develop:
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
	bash execRioneLauncherInDocker.sh ${NAME} 1

rioneLauncher-score-upload:
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
	bash execRioneLauncherInDocker.sh ${NAME} 1
	make score-upload

score-upload:
	bash scoreUpload.sh ${SCORE_FILE}


# dockerのリソースを開放
clean:
	docker system prune

# キャッシュを使わずにビルド
rebuild:
	@echo "コンテナの再構築には時間がかかります"
	@echo "コンテナを再構築しますか？ (y/n)"
	@read -p "->" ans;\
	if [ "$$ans" != y ]; then  \
      exit 1;\
    fi
	DOCKER_BUILDKIT=1 docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} \
	--pull \
	--force-rm=true \
	--no-cache=true .

# root権限で起動中のコンテナに接続
connect:
	docker exec -u root -it ${NAME} /bin/bash

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
ifneq ($(shell docker ps -a | grep ${NAME}),)
	docker container stop ${NAME}
endif

testInContainer:
	sed -i -e 's/kernel.timesteps: 300/kernel.timesteps: 10/' ~/rcrs-server-1.5/maps/gml/test/config/kernel.cfg

# github actions用
# github actionsにはTTYがないので-itが使えない
# -itを使えないとrun状態でコンテナを待機させられないので疑似TTYを使うためのfakettyをTTYの使用するコマンドの先頭につける
github-actions-test:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	faketty docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	docker container ls
	# bash dockerCp.sh ${NAME} ${DOCKER_HOME_DIR}
	docker cp makefile ${NAME}:${DOCKER_HOME_DIR}/RioneLauncher/makefile
	docker container exec -d ${NAME} make testInContainer
	bash execRioneLauncherInDocker.sh ${NAME} debug

# テストマップの時間を10サイクルに変更
# テストする際に300サイクル待っていられないので作成
testInContainer:
	sed -i -e 's/kernel.timesteps: 300/kernel.timesteps: 10/' ~/rcrs-server-1.5/maps/gml/test/config/kernel.cfg

# github actions用
# github actionsにはTTYがないので-itが使えない
# -itを使えないとrun状態でコンテナを待機させられないので疑似TTYを使うためのfakettyをTTYの使用するコマンドの先頭につける
github-actions-test:
	touch ${SCORE_FILE}
	bash dockerContainerStop.sh ${NAME}
	faketty docker container run \
	-it \
	--rm \
	-d \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=${DOCKER_HOME_DIR}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest
	docker container ls
	docker cp makefile ${NAME}:${DOCKER_HOME_DIR}/RioneLauncher/makefile
	docker container stop ${NAME}

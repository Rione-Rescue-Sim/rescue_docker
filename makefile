NAME := rescue_d
TS := `date +%Y%m%d%H%M%S`
SCORE_FILE := score.csv
DOCKER_USER_NAME := guest
CURRENT_PATH := $(Shell pwd)
MOUNT_DIR := mount

help:
	@echo "----------------------------------"
	@echo "レスキュー実行手順"
	@echo "1. make build"
	@echo "2. make run"
	@echo "----------------------------------"
	@echo "##注意##"
	@echo "コンテナ内のデータはレスキューのスコアのみ保存されます。"
	@echo "それ以外のデータはコンテナ終了時にすべて破棄されます。"
	@echo "コンテナ内での開発はしないでください、コンテナ終了時に消えます。"
	@echo "新しいパッケージを導入する場合はDocker fileを編集してください。"
	@echo "----------------------------------"
	@echo "コマンド一覧"
	@echo "make build\tキャッシュありでビルド"
	@echo "make rebuild\tキャッシュなしでビルド"
	@echo "\t\tキャッシュを使用->サーバは更新されないが短時間でビルド可能"
	@echo "\t\tキャッシュを使用しない->サーバを更新してビルド"
	@echo ""
	@echo "make run\tコンテナを起動"
	@echo ""
	@echo "make clean\tコンテナとイメージを削除"
	@echo "\t\t命令はdocker system pluneなので他のDockerイメージも消えます"
	@echo ""
	@echo "make connect\t起動中のコンテナにroot権限で接続"
	@echo "\t\t使用例：新しいパッケージの導入テストなど"
	@echo ""
	@echo "make install\tDockerの環境構築"
	@echo "----------------------------------"

# キャッシュ有りでビルド
build:
	bash rescue2docker.sh
	docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} .

# コンテナ実行
run:
	xhost local:
	touch ${SCORE_FILE}
	docker container run \
	-it \
	--rm \
	--name ${NAME} \
	--mount type=bind,src=$(PWD)/${SCORE_FILE},dst=/root/${DOCKER_USER_NAME}/RioneLauncher/${SCORE_FILE} \
	-e DISPLAY=unix${DISPLAY} \
	-v /tmp/.X11-unix/:/tmp/.X11-unix \
	${NAME}:latest

# dockerのリソースを開放
clean:
	docker system prune

# キャッシュを使わずにビルド
rebuild:
	bash rescue2docker.sh
	docker image build -t ${NAME} \
	--build-arg CACHEBUST=${TS} \
	--pull \
	--no-cache=true .

# root権限で起動中のコンテナに接続
connect:
	docker exec -u root -it ${NAME} /bin/bash

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
	sudo docker run --rm hello-world
	sudo docker rmi hello-world
	ifeq ($(Shell getent group docker), $(EMPTY))
	exit
	endif
	-@sudo groupadd docker
	-@sudo gpasswd -a $(whoami) docker
	sudo chgrp docker /var/run/docker.sock
	sudo systemctl restart docker
	sudo systemctl status docker
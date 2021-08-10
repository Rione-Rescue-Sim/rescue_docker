NAME := rescue_d
TS := `date +%Y%m%d%H%M%S`
SCORE_FILE := score.csv
DOCKER_USER_NAME := guest
CURRENT_PATH := $(Shell pwd)
MOUNT_DIR := mount

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
	--no-cache=true .

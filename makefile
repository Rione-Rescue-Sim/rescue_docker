NAME := rescue_d
TS=`date +%Y%m%d%H%M%S`

# キャッシュ有りでビルド
build:
	bash rescue2docker.sh
	docker image build -t ${NAME} --build-arg CACHEBUST=${TS} .

# コンテナ実行
run: 
	xhost local:
	docker run -it --rm -e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix ${NAME}:latest

# dockerのリソースを開放
clean:
	docker system prune

# キャッシュを使わずにビルド
rebuild:
	bash rescue2docker.sh
	docker image build -t ${NAME} --build-arg CACHEBUST=${TS} --no-cache=true .

NAME := rescue_d

build:
	docker image build -t ${NAME} .

run: 
	docker run -it --rm -e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --net=host ${NAME}:latest #-login
	
clean:
	docker system prune

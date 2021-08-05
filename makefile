NAME := rescue_d
FLAGS	:= -c -Wall -O1

build:
	docker image build -t ${NAME} .

run: 
	docker run -it --rm -e DISPLAY=unix${DISPLAY} -v /tmp/.X11-unix/:/tmp/.X11-unix --net=host ${NAME}:latest -login
	
clean container:
	docker container prune

clean image:
	docker image prune

deep clean:
	docker system prune

restart:
	docker container restart ${NAME}:latest
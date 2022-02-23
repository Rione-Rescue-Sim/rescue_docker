# !/bin/bash

NAME=$1

if docker container ps | grep ${NAME} 2>/dev/null; then
echo "container stop"
docker container rm ${NAME}
fi
# !/bin/bash

NAME=$1

if $(docker container ps | grep "${NAME}"); then
echo "container stop"
# docker container stop ${NAME}
fi
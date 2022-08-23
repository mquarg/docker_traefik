#!/bin/bash

CUR_DATE=`date '+%Y%m%d-%H%M'`

cp /var/log/traefik.log /var/log/traefik.log.${CUR_DATE}
gzip /var/log/traefik.log.${CUR_DATE}
> /var/log/traefik.log

INST_DIR=/opt/traefik
BIN_DIR=${INST_DIR}/bin
ETC_DIR=${INST_DIR}/etc

CNT=`docker ps -a -f name=traefik|grep traefik| wc -l`

if [ $CNT -eq 1 ]; then
	docker stop traefik || true
	docker rm traefik || true
fi

echo "start Traefik"
docker run --name traefik -d -p 8080:8080 -p 80:80 -p 443:443 \
-v /var/log/traefik.log:/var/log/traefik.log \
-v ${ETC_DIR}/traefik.yml:/etc/traefik/traefik.yml \
-v ${ETC_DIR}/fileconfig:/etc/traefik/fileconfig \
-v /var/run/docker.sock:/var/run/docker.sock \
traefik:v2.8.3

tail -f /var/log/traefik.log
#!/bin/bash

CUR_DATE=`date '+%Y%m%d-%H%M'`

LOGFILE=/var/log/traefik.log

if [ -f ${LOGFILE} ]; then
	echo "LOGFILE: ${LOGFILE}"
	mv ${LOGFILE} ${LOGFILE}.${CUR_DATE}
	gzip ${LOGFILE}.${CUR_DATE}
fi
touch ${LOGFILE}

INST_DIR=/opt/traefik
BIN_DIR=${INST_DIR}/bin
ETC_DIR=${INST_DIR}/etc

CNT=`docker ps -a -f name=traefik|grep traefik| wc -l`

if [ $CNT -eq 1 ]; then
	docker stop traefik || true
	docker rm traefik || true
fi

echo "start Traefik"
docker run --name traefik -d --restart always -p 8080:8080 -p 80:80 -p 443:443 -p 7999:7999 \
-v ${LOGFILE}:${LOGFILE} \
-v ${ETC_DIR}/traefik.yml:/etc/traefik/traefik.yml \
-v ${ETC_DIR}/fileconfig:/etc/traefik/fileconfig \
-v ${ETC_DIR}/certs:/etc/traefik/certs \
-v /var/run/docker.sock:/var/run/docker.sock \
traefik:v2.8.3

tail -f ${LOGFILE}
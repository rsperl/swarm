#!/bin/bash

docker network create -d overlay mynet
docker service create --name frontend --replicas 3 -e MYPORT=80 -e MYHOST=0.0.0.0 -p 80:80/tcp --network mynet server
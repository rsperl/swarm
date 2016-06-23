# Deploying Services with Docker Swarm

**The binary src/static-file-server is compiled by running ```GOOS=linux go build -o static-file-server static-file-server.go``` from a valid GOPATH.**

1. Create the swarm cluster
1. Create a three-node cluster sw1, sw2, and sw3

    ./swarm.sh sw 3

1. Convert the compose file to a bundle

    docker-compose bundle

1. Do the things it won't

    docker network create -d overlay mynetwork

1. Create the network

    docker network create -d overlay mynet

1. Create the service

    docker service create --name frontend --replicas 3 -e MYPORT=80 -e MYHOST=0.0.0.0 -p 80:80/tcp --network mynet server


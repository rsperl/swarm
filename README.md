# Deploying Services with Docker Swarm

**The binary src/static-file-server is compiled by running ```GOOS=linux go build -o static-file-server static-file-server.go``` from a valid GOPATH.**

1. Create the swarm cluster
1. Create a three-node cluster sw1, sw2, and sw3

    ./swarm.sh sw 3

1. Convert the compose file to a bundle

    docker-compose bundle

1. Do the things it won't

    docker network create -d overlay mynetwork

1. Deploy the service

    docker deploy sfs

1. Configure the service

    docker service update -p 30000:3000 sfs_staticfileserver
    docker service scale sfs_staticfileserverfs=3


__The problem I've run into is that ```docker deploy sfs``` doesn't expose the port the way I think it should. Have I missed something?__

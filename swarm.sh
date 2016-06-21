#!/bin/bash

ACTION=$1
NODEPREFIX=$2
NNODES=$3

ports="2377 7946 4789"
boot2dockerurl=https://github.com/boot2docker/boot2docker/releases/download/v1.12.0-rc2/boot2docker.iso
boot2docker=./boot2docker.iso

function downloadboot2docker() {
    if [ ! -f $boot2docker ] ; then
        curl -Lo $boot2docker $boot2dockerurl
    fi
}

function swarmmake() {
    for n in `seq 1 $NNODES`
    do
        vm=$NODEPREFIX$n
        docker-machine create --virtualbox-boot2docker-url $boot2docker --driver virtualbox $vm
    done
}

function getip() {
    local machine=$1
    docker-machine ls | grep $machine | awk '{print $5}' | sed -e 's/tcp:\/\///' | sed -e 's/6$/7/'
}

function getnodeid() {
    local master=$1
    docker $(docker-machine config $master) node ls | grep -i pending | head -1 | awk '{print $1}'
}

function swarmconfigure() {
    local master=${NODEPREFIX}1
    local masterip=$(getip $master)
    docker $(docker-machine config $master) swarm init --listen-addr $masterip

    for n in `seq 2 $NNODES`
    do
        local vm=$NODEPREFIX$n
        local ip=$(getip $vm)
        docker $(docker-machine config $vm) swarm join --manager --listen-addr $ip $masterip
        local id=$(getnodeid $master)
        docker $(docker-machine config $master) node accept $id
    done
}

function swarmdestroy() {
    for n in `seq 1 $NNODES`
    do
        local vm=$NODEPREFIX$n
        docker-machine rm --force $vm
    done
}

function swarmrestart() {
    for n in `seq 1 $NNODES`
    do
        local vm=$NODEPREFIX$n
        docker-machine stop  $vm
        docker-machine start $vm
    done
}

function fixports() {
    for p in `echo $ports`
    do
        for n in `seq 1 $NNODES`
        do
            local vm=$NODEPREFIX$n
            vboxmanage controlvm $vm natpf1 "tcp_$p,tcp,,$p,,$p"
            vboxmanage controlvm $vm natpf1 "udp_$p,udp,,$p,,$p"
        done
    done
}

if [ -z $ACTION ] ; then
    echo "Usage:"
    echo "  $0 create <nodeprefix> <number of nodes>"
    echo "  $0 destroy <nodeprefix> <number of nodes>"
elif [ $ACTION = "create" ] ; then
    downloadboot2docker
    swarmmake
    fixports
    swarmconfigure
elif [ $ACTION = "destroy" ] ; then
    swarmdestroy
else
    echo "invalid action '$ACTION'"
fi

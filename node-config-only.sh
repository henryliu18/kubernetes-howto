#!/bin/bash

#node-config-only.sh
#
#We expect that all required packages such as docker, kube* to be installed as prerequisites
#This script is only for node to join k8s cluster

echo Hostname:
read THIS_NODE_HOST
echo IP address:
read THIS_NODE_IP
echo MASTER IP address:
read MAS_NODE_IP
echo JOIN command:
read JOINCMD

sudo scp root@$MAS_NODE_IP:/etc/hosts /etc/hosts
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
echo -e "${THIS_NODE_IP} ${THIS_NODE_HOST}" | sudo tee -a /etc/hosts && \
sudo scp /etc/hosts root@$MAS_NODE_IP:/etc/hosts
sudo bash -c "$JOINCMD"

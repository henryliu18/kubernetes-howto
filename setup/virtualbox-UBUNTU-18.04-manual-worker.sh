#!/bin/bash

#Ubuntu 18.04/K8S worker node
echo Hostname:
read THIS_NODE_HOST
echo JOIN command:
read JOINCMD

#set hostname and sync /etc/hosts
until [ "${x}" = 'yes' ];
do
  clear
  echo "Make sure /etc/hosts has both master and all worker entries
Hit yes to continue..."
  read x
done
sudo vi /etc/hosts && \
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \

#install required tools
sudo apt install net-tools ssh curl -y && \

#BEGIN
sudo apt-get update -y && \
sudo apt install docker.io -y && \
sudo systemctl enable docker && \
echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" | sudo tee -a /etc/docker/daemon.json && \
sudo systemctl restart docker && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add && \
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" -y && \
sudo apt install kubeadm -y && \
sudo swapoff -a && \
sudo systemctl enable kubelet.service && \
sleep 30 && \
sudo bash -c "$JOINCMD"
#END

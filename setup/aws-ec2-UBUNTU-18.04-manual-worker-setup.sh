#!/bin/bash

#KUBERNETES WORKER NODE BUILD FOR AWS EC2 UBUNTU 18.04 LTS

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
sudo swapoff -a
echo "Essential installation is completed successfully
Run sudo kubeadm join cluster, this command can be found in master node at ~/k8sinit.log"
#END

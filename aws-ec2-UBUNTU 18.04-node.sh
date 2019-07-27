#!/bin/bash

#KUBERNETES SLAVE NODE BUILD FOR AWS EC2 UBUNTU 18.04 LTS

#CHANGE BELOW HOSTNAME
host_name='slave-node1'
int_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

#BEGIN
sudo hostnamectl set-hostname ${host_name} && \
echo -e "${int_ip} ${host_name}" | sudo tee -a /etc/hosts && \
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
sudo kubeadm join 172.31.12.237:6443 --token e7bf77.5j7v84ge0eey918w --discovery-token-ca-cert-hash sha256:b857329fd3bfbb97b3380a46bc16644d5bec9c9fe7a5d0bb8e4dfff1ded01956
#END

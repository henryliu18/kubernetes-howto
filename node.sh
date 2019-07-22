#!/bin/bash

#variables
THIS_NODE_HOST=k8snode1

#install required tools
sudo yum install yum-utils device-mapper-persistent-data lvm2 ipset ipvsadm git xorg-x11-xauth -y

#hostname
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
sudo cat hosts >> /etc/hosts

#firewalld
sudo systemctl stop firewalld && \
sudo systemctl disable firewalld && \
sudo setenforce 0 && \
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#kernel params
echo -e "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0" | sudo tee -a /etc/sysctl.d/k8s.conf && \
sudo modprobe br_netfilter && \
sudo sysctl -p /etc/sysctl.d/k8s.conf

#ipvs module
echo -e '#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4' | sudo tee -a /etc/sysconfig/modules/ipvs.modules
sudo chmod 755 /etc/sysconfig/modules/ipvs.modules && \
sudo bash /etc/sysconfig/modules/ipvs.modules && \
sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv4

#install and configure docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
sudo yum install -y --setopt=obsoletes=0 docker-ce-18.09.7-3.el7 && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" | sudo tee -a /etc/docker/daemon.json && \
sudo systemctl restart docker

#install kubeadm and kubelet
echo -e "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | sudo tee -a /etc/yum.repos.d/kubernetes.repo && \
sudo yum install -y kubelet kubeadm kubectl

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab

#start kubelet
sudo systemctl enable kubelet.service

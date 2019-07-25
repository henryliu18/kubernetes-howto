#!/bin/bash

#master-config-only.sh
#
#We expect that all required packages such as docker, kube* to be installed as prerequisites
#This script is only for master node init configuration such as init cluster, network, dashboard etc..

echo Hostname:
read THIS_NODE_HOST
echo IP address:
read THIS_NODE_IP

LOGFILE=/tmp/k8smaster.log

sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
echo -e "${THIS_NODE_IP} ${THIS_NODE_HOST}" | sudo tee -a /etc/hosts

echo -e "apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${THIS_NODE_IP}
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.15.0
networking:
  podSubnet: 10.244.0.0/16" | sudo tee -a /tmp/kubeadm.yaml
sudo kubeadm init --config /tmp/kubeadm.yaml >> ${LOGFILE}

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#deploy dashboard (localhost only)
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
sudo kubectl create serviceaccount dashboard -n default >> ${LOGFILE}
sudo kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard >> ${LOGFILE}
sudo kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode >> ${LOGFILE}


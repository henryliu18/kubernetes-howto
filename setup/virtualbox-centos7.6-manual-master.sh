#!/bin/bash

#run as root/CentOS 7.6/K8S master ndoe
echo Hostname:
read THIS_NODE_HOST
echo IP address:
read THIS_NODE_IP

LOGFILE=/tmp/k8smaster.log

#install required tools
sudo yum install yum-utils device-mapper-persistent-data lvm2 ipset ipvsadm git xorg-x11-xauth -y && \

#hostname
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
echo -e "${THIS_NODE_IP} ${THIS_NODE_HOST}" | sudo tee -a /etc/hosts && \

#firewalld
sudo systemctl stop firewalld && \
sudo systemctl disable firewalld && \
sudo setenforce 0 && \
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && \

#kernel params
echo -e "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0" | sudo tee -a /etc/sysctl.d/k8s.conf && \
sudo modprobe br_netfilter && \
sudo sysctl -p /etc/sysctl.d/k8s.conf && \

#ipvs module
echo -e '#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4' | sudo tee -a /etc/sysconfig/modules/ipvs.modules && \
sudo chmod 755 /etc/sysconfig/modules/ipvs.modules && \
sudo bash /etc/sysconfig/modules/ipvs.modules && \
sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv4 && \

#install and configure docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
sudo yum install -y --setopt=obsoletes=0 docker-ce-18.09.7-3.el7 && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" | sudo tee -a /etc/docker/daemon.json && \
sudo systemctl restart docker && \

#install kubeadm and kubelet
echo -e "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | sudo tee -a /etc/yum.repos.d/kubernetes.repo && \
sudo yum install -y kubelet kubeadm kubectl && \

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab && \

#start kubelet
sudo systemctl enable kubelet.service && \

#init k8s cluster
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
kubernetesVersion: v1.16.1
networking:
  podSubnet: 192.168.0.0/16" | sudo tee -a /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU >> ${LOGFILE} && \
sleep 30 && \

#how a regular user access kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

#Deploy Pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && \
sleep 30 && \

#install Google chrome
sudo yum install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y && \
sudo yum install libGL -y && \

#deploy dashboard (localhost only)
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml && \
sudo kubectl create serviceaccount dashboard -n default >> ${LOGFILE} && \
sudo kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard >> ${LOGFILE} && \
sudo kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode >> ${LOGFILE} && \

#install HELM
sudo curl -O https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v2.14.1-linux-amd64.tar.gz && \
sudo cp linux-amd64/helm /usr/local/bin/ && \

echo -e "apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system" | sudo tee -a /tmp/helm-rbac.yaml && \
kubectl create -f /tmp/helm-rbac.yaml && \
helm init --service-account tiller --skip-refresh

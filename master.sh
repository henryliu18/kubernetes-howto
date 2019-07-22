#!/bin/bash

#variables
THIS_NODE_HOST=k8smaster
THIS_NODE_IP=192.168.56.103
LOGFILE=/tmp/k8smaster.log

#install required tools
sudo yum install yum-utils device-mapper-persistent-data lvm2 ipset ipvsadm git -y

#hostname
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
sudo cat hosts >> /etc/hosts

#firewalld
sudo systemctl stop firewalld && \
sudo systemctl disable firewalld && \
sudo setenforce 0 && \
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#kernel params
sudo echo -e "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0" >> /etc/sysctl.d/k8s.conf && \
sudo modprobe br_netfilter && \
sudo sysctl -p /etc/sysctl.d/k8s.conf

#ipvs module
sudo cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
sudo chmod 755 /etc/sysconfig/modules/ipvs.modules && \
sudo bash /etc/sysconfig/modules/ipvs.modules && \
sudo lsmod | grep -e ip_vs -e nf_conntrack_ipv4

#install and configure docker
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
sudo yum makecache fast && \
sudo yum install -y --setopt=obsoletes=0 docker-ce-18.09.7-3.el7 && \
sudo systemctl start docker && \
sudo systemctl enable docker && \
sudo echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" >> /etc/docker/daemon.json && \
sudo systemctl restart docker

#install kubeadm and kubelet
sudo cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
sudo yum install -y kubelet kubeadm kubectl

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab

#start kubelet
sudo systemctl enable kubelet.service

#init k8s cluster (master)
sudo echo -e "apiVersion: kubeadm.k8s.io/v1beta2
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
  podSubnet: 10.244.0.0/16" > /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml >> ${LOGFILE}

#how a regular user access kubectl
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

#Deploy Pod network
sudo mkdir -p /tmp/k8s/
sudo cd /tmp/k8s
sudo curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo kubectl apply -f /tmp/k8s/kube-flannel.yml

#install Google chrome
sudo wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
sudo yum install ./google-chrome-stable_current_*.rpm -y && \
sudo yum install libGL -y

#deploy dashboard (localhost only)
sudo kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta1/aio/deploy/recommended.yaml
sudo kubectl create serviceaccount dashboard -n default >> ${LOGFILE}
sudo kubectl create clusterrolebinding dashboard-admin -n default --clusterrole=cluster-admin --serviceaccount=default:dashboard >> ${LOGFILE}
sudo kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode >> ${LOGFILE}

# #dashboard start and ui login
# kubectl proxy

# #login url
# http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

# #below is optional
# #check pods status (optional)
# kubectl get pod -n kube-system -o wide

# #install HELM (optional)
# curl -O https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
# tar -zxvf helm-v2.14.1-linux-amd64.tar.gz
# cd linux-amd64/
# cp helm /usr/local/bin/

# echo -e "apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: tiller
#   namespace: kube-system
# ---
# apiVersion: rbac.authorization.k8s.io/v1beta1
# kind: ClusterRoleBinding
# metadata:
#   name: tiller
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# subjects:
#   - kind: ServiceAccount
#     name: tiller
#     namespace: kube-system" > /tmp/helm-rbac.yaml

# kubectl create -f /tmp/helm-rbac.yaml

# #deploy tiller (optional)
# helm init --service-account tiller --skip-refresh

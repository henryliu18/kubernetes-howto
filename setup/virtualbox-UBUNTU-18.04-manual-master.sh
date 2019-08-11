#!/bin/bash

#Ubuntu 18.04/K8S master node
echo Hostname:
read THIS_NODE_HOST
echo IP address:
read THIS_NODE_IP

LOGFILE=~/k8sinit.log

#install required tools
sudo apt install net-tools ssh curl -y && \

#hostname
sudo hostnamectl set-hostname ${THIS_NODE_HOST} && \
echo -e "${THIS_NODE_IP} ${THIS_NODE_HOST}" | sudo tee -a /etc/hosts && \

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
  podSubnet: 10.244.0.0/16" | sudo tee -a /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > ${LOGFILE} && \
mkdir -p ~/.kube && \
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config && \
sudo chown $(id -u):$(id -g) ~/.kube/config && \
sudo curl -O https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && \
until [ "${x}" = 'yes' ];
do
  clear
  echo "you will edit file kube-flannel.yml if your system has multiple NICs, see below example
containers:
- name: kube-flannel
image: quay.io/coreos/flannel:v0.11.0-amd64
command:
- /opt/bin/flanneld
args:
- --ip-masq
- --kube-subnet-mgr
- --iface=eth1 #Add this line and replace eth1 with your NIC name
Hit yes to continue..."
  read x
done
sudo vi kube-flannel.yml && \
sudo kubectl apply -f kube-flannel.yml && \
echo "alias k='kubectl'" | sudo tee -a ~/.bashrc && \
echo "alias kpod='kubectl get pod -o wide --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias ksvc='kubectl get svc -o wide --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias king='kubectl get ingress --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias knod='kubectl get node -o wide'" | sudo tee -a ~/.bashrc && \
echo "alias klog='kubectl logs'" | sudo tee -a ~/.bashrc && \
echo "alias kexe='kubectl exec'" | sudo tee -a ~/.bashrc && \
echo "alias kdep='kubectl get deployment -o wide --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias gettoken='kubectl describe -n kube-system secret/$(kubectl -n kube-system get secret | grep kubernetes-dashboard-token|cut -d" " -f1)'" | sudo tee -a ~/.bashrc && \
sleep 30 && \
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
sudo kubectl create -f /tmp/helm-rbac.yaml && \
sudo helm init --service-account tiller --skip-refresh
echo "Cluster init and helm installtion is completed successfully"
#END

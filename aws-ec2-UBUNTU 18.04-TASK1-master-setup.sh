#!/bin/bash

#KUBERNETES MASTER NODE BUILD FOR AWS EC2 UBUNTU 18.04 LTS

#BEGIN
int_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
sudo apt-get update -y && \
sudo apt install docker.io -y && \
sudo systemctl enable docker && \
echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" | sudo tee -a /etc/docker/daemon.json && \
sudo systemctl restart docker && \
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add && \
sudo apt-get install software-properties-common -y && \
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main" -y && \
sudo apt install kubeadm -y && \
sudo swapoff -a && \
echo -e "apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: ${int_ip}
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
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > /tmp/k8sinit.log && \
mkdir -p ~/.kube && \
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config && \
sudo chown $(id -u):$(id -g) ~/.kube/config && \
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && \
echo "alias k='kubectl'" | sudo tee -a ~/.bashrc && \
echo "alias kpod='kubectl get pod -o wide --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias ksvc='kubectl get svc -o wide --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias king='kubectl get ingress --all-namespaces'" | sudo tee -a ~/.bashrc && \
echo "alias knod='kubectl get node -o wide'" | sudo tee -a ~/.bashrc && \
echo "alias kdep='kubectl get deployment -o wide --all-namespaces'" | sudo tee -a ~/.bashrc

#Install helm - The Kubernetes Package Manager
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
#END

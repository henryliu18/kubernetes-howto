# K8s 1.15.3 software installation (control plane and worker) - 2 vCPU, 7.5 GB, Centos 7
```
#install required tools
sudo yum install yum-utils lvm2 ipset ipvsadm -y && \

#firewalld
sudo systemctl stop firewalld && \
sudo systemctl disable firewalld && \
sudo setenforce 0 && \
sudo sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux && \

#kernel params
echo -e "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0" | sudo tee /etc/sysctl.d/k8s.conf && \
sudo modprobe br_netfilter && \
sudo sysctl -p /etc/sysctl.d/k8s.conf && \

#ipvs module
echo -e '#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4' | sudo tee /etc/sysconfig/modules/ipvs.modules && \
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
}" | sudo tee /etc/docker/daemon.json && \
sudo systemctl restart docker && \

#install kubeadm and kubelet
echo -e "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | sudo tee /etc/yum.repos.d/kubernetes.repo && \
sudo yum install -y kubelet-1.15.3 kubectl-1.15.3 kubeadm-1.15.3 && \

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab && \

#start kubelet
sudo systemctl enable kubelet.service
```

# init k8s cluster, pod network
```
echo -e "apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: $(hostname -I | awk -F ' ' '{print $1}')
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.15.3
networking:
  podSubnet: 10.244.0.0/16" | sudo tee /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > ~/k8s.log && \
sleep 30 && \

#how a regular user access kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

#Deploy Pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

# alias
```
echo -e "
alias k='kubectl'
alias kdep='kubectl get deployment -o wide --all-namespaces'
alias kpod='kubectl get pod -o wide --all-namespaces'
alias ksvc='kubectl get svc -o wide --all-namespaces'
alias king='kubectl get ingress --all-namespaces'
alias knod='kubectl get node -o wide'
alias klog='kubectl logs'
alias kexe='kubectl exec'
alias kdel='kubectl delete'
alias kwatch='watch kubectl get node,deployment,pod,svc,ing,pv,pvc,sc,sts,job -o wide'
alias c='cat <<EOF | kubectl apply -f -'" >> ~/.bashrc
```

# Join cluster from worker nodes

# Tool - HELM 2.14.3 installation on master node
* https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/helm/README.md#helm-2143-binaries

# (optional) METALLB installation on master node
* https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/metallb#metallb-is-a-load-balancer-implementation-for-bare-metal-kubernetes-clusters-using-standard-routing-protocols

# Istio
* https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/istio

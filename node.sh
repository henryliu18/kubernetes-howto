#!/bin/bash

THIS_NODE_HOST=k8snode1

#hostname
hostnamectl set-hostname ${THIS_NODE_HOST} && \
cat hosts >> /etc/hosts

#firewalld
systemctl stop firewalld && \
systemctl disable firewalld && \
setenforce 0 && \
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

#kernel params
echo -e "net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
vm.swappiness=0" >> /etc/sysctl.d/k8s.conf && \
modprobe br_netfilter && \
sysctl -p /etc/sysctl.d/k8s.conf

#ipvs module
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack_ipv4
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules && \
bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep -e ip_vs -e nf_conntrack_ipv4

#tools
yum install yum-utils device-mapper-persistent-data lvm2 ipset ipvsadm -y

#install and configure docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo && \
yum makecache fast && \
yum install -y --setopt=obsoletes=0 docker-ce-18.09.7-3.el7 && \
systemctl start docker && \
systemctl enable docker && \
echo -e "{
  \"exec-opts\": [\"native.cgroupdriver=systemd\"]
}" >> /etc/docker/daemon.json && \
systemctl restart docker

#install kubeadm and kubelet
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl

#swap off
swapoff -a && \
sed -i '/ swap / s/^/#/' /etc/fstab

#start kubelet
systemctl enable kubelet.service

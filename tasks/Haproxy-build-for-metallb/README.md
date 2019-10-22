# Haproxy build - 1 vCPU, 1.7 GB, Centos 7, default-allow-http, default-allow-https, k8s-worker
```
#install required tools
sudo yum install yum-utils lvm2 ipset ipvsadm haproxy -y && \

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

## Add Haproxy node to the cluster (example)
```
sudo kubeadm join 10.128.0.31:6443 --token vg477j.rp1r7luon9fxjypc \
    --discovery-token-ca-cert-hash sha256:918b805f68e6308b8ce85a743774e607a17f731f3a1bbb64ffd4a5bc4ce66472
```

## Cordon haproxy node on master node so nothing will be scheduled to this special node
```kubectl cordon haproxy1```

## Testing metallb endpoint from haproxy node
```curl http://10.244.1.220/hello -HHost:hello.busyapi.com```

## Configure Haproxy for metallb endpoint
```
echo '#---------------------------------------------------------------------
# FrontEnd Configuration for HTTP
#---------------------------------------------------------------------
frontend main
    bind *:80
    option http-server-close
    option forwardfor
    default_backend app-main

#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm for HTTP
#---------------------------------------------------------------------
backend app-main
    balance roundrobin                                     #Balance algorithm
#    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server application is up and healty - 200 status code
    server node1 10.244.1.220:80 check

#---------------------------------------------------------------------
# FrontEnd Configuration for HTTPS
#---------------------------------------------------------------------
frontend main-ssl
    bind *:443
    option tcplog
    mode tcp
    default_backend nodes-ssl

#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm for HTTPS
#---------------------------------------------------------------------
backend nodes-ssl
    mode tcp
    balance roundrobin
    option ssl-hello-chk
    server node1 10.244.1.220:443 check
' | sudo tee -a /etc/haproxy/haproxy.cfg && \
sudo systemctl start haproxy && \
sudo systemctl enable haproxy
```

## Below should work when DNS A record pointing to haproxy node public ip
```curl http://hello.busyapi.com/hello```
* [TROUBLESHOOTING] If you getting connection refused, restart haproxy

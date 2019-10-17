# Baremetal style of K8s 1.15.3/metallb/istio/cert-manager deployment with Haproxy and cloud vendor managed load balancer for external access via an external dns server

## Requirements:
* 2 VMs for K8s master and worker node (public ip)
* 2 VMs for Haproxy (public ip)
* 1 cloud vendor managed Load Balancer (public ip)
* 1 valid DNS record that points to Load Balancer
* 1 email address for creating Let's encrypt certificate

## Deployment steps
* K8s stack (K8s/helm/metallb/istio/cert-manager)
* DNS validation
* Haproxy installation and configuration
* Container deployment (Tomcat)
* Create Let's encrypt certificate for Tomcat web server

## K8s master build - 2 vCPU, 7.5 GB, Centos 7
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
sudo yum install -y kubelet-1.15.3 kubectl-1.15.3 kubeadm-1.15.3 && \

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab && \

#start kubelet
sudo systemctl enable kubelet.service && \

#init k8s cluster
echo -e "apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 10.0.0.10
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
  podSubnet: 10.244.0.0/16" | sudo tee -a /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > ~/k8s.log && \
sleep 30 && \

#how a regular user access kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

#Deploy Pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

## K8s worker build - 2 vCPU, 7.5 GB, Centos 7
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
sudo yum install -y kubelet-1.15.3 kubectl-1.15.3 kubeadm-1.15.3 && \

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab && \

#start kubelet
sudo systemctl enable kubelet.service
```

## Add worker nodes to cluster (change this applying to your cluster)
```
sudo kubeadm join 10.128.0.31:6443 --token vg477j.rp1r7luon9fxjypc \
    --discovery-token-ca-cert-hash sha256:918b805f68e6308b8ce85a743774e607a17f731f3a1bbb64ffd4a5bc4ce66472
```

## HELM 2.14.1 installation on master node
```
sudo curl -O https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v2.14.1-linux-amd64.tar.gz && \
sudo cp linux-amd64/helm /usr/local/bin/

cat <<EOF | kubectl create -f -
apiVersion: v1
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
    namespace: kube-system
EOF

helm init --service-account tiller --skip-refresh
helm repo update
```

## METALLB installation on master node
```
helm install --name metallb stable/metallb --namespace metallb-system

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: metallb-config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.244.1.220-10.244.1.250              #gives MetalLB control over cluster IP range
EOF
```

## Create crds for cert-manager
```kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml```

## ISTIO-INIT
```
helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.1.2/charts/
helm repo update
helm install istio.io/istio-init --name istio-init --namespace istio-system
```

## Create Kiali secret (optional)
```
KIALI_USERNAME=$(echo -n admin | base64)
KIALI_PASSPHRASE=$(echo -n pass | base64)
NAMESPACE=istio-system
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $NAMESPACE
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
```

## ISTIO with sds enabled, Prometheus, Grafana and Kiali
```
helm install istio.io/istio \
       --name istio \
       --namespace istio-system \
       --set gateways.istio-ingressgateway.sds.enabled=true \
       --set global.k8sIngress.enabled=true \
       --set global.k8sIngress.enableHttps=true \
       --set global.k8sIngress.gatewayName=ingressgateway \
       --set certmanager.enabled=true \
       --set certmanager.email=henry.hhl@gmail.com \
       --set grafana.enabled=True \
       --set kiali.enabled=True
```

## Cert-manager v0.10.1 (to be deleted)
```
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install jetstack/cert-manager --version v0.10.1 --namespace cert-manager --name cert-manager
```

## Tomcat server deployment on default namespace with istio-injection
```
kubectl label ns default istio-injection=enabled

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: tomcat
  name: tomcat-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      run: tomcat
  template:
    metadata:
      labels:
        run: tomcat
    spec:
      containers:
      - image: tomcat:alpine
        name: tomcat
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: tomcat-service
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    run: tomcat
  type: ClusterIP
EOF
```

## Gateway istio-autogenerated-k8s-ingress is created by default
* Accepting any header host for http/https protocol ingress control
* To restrict incoming request header host, specifying "example.com" to Hosts in yaml

```kubectl describe gateway/istio-autogenerated-k8s-ingress -n istio-system```

## Create Istio virtualservice
* uri prefix "/" accepts any request that beginning with "/"
* route defines which service and port to send request to

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: tomcat-vs
spec:
  hosts:
  - "*"
  gateways:
  - istio-system/istio-http-gw-ingress
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: tomcat-service
        port:
          number: 8080
---
EOF
```

## Testing metallb endpoint of Tomcat service
```curl http://10.244.1.220/ -HHost:a.com```

## Haproxy build - 1 vCPU, 1.7 GB, Centos 7, default-allow-http, default-allow-https, k8s-worker
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
sudo yum install -y kubelet-1.15.3 kubectl-1.15.3 kubeadm-1.15.3 && \

#swap off
sudo swapoff -a && \
sudo sed -i '/ swap / s/^/#/' /etc/fstab && \

#start kubelet
sudo systemctl enable kubelet.service
```

## Add Haproxy node to the cluster
```
sudo kubeadm join 10.128.0.31:6443 --token vg477j.rp1r7luon9fxjypc \
    --discovery-token-ca-cert-hash sha256:918b805f68e6308b8ce85a743774e607a17f731f3a1bbb64ffd4a5bc4ce66472
```

## Cordon haproxy node on master node
```kubectl cordon haproxy1```

## Testing metallb endpoint of Tomcat service from haproxy node
```curl http://10.244.1.220/ -HHost:a.com```

## Configure Haproxy for metallb endpoint
```
echo '#---------------------------------------------------------------------
# FrontEnd Configuration
#---------------------------------------------------------------------
frontend main
    bind *:80
    option http-server-close
    option forwardfor
    default_backend app-main

#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm
#---------------------------------------------------------------------
backend app-main
    balance roundrobin                                     #Balance algorithm
    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server application is up and healty - 200 status code
    server node1 10.244.1.220:80 check
' | sudo tee -a /etc/haproxy/haproxy.cfg && \
sudo systemctl start haproxy && \
sudo systemctl enable haproxy
```

## Testing haproxy endpoint of Tomcat service from haproxy node
```curl http://localhost/ -HHost:a.com```

## Testing haproxy endpoint of Tomcat service from public ip
```http://<haproxy-node1-ip>/```

## Set up DNS A record for a.com -> public ip of haproxy node and test it
```http://a.com/```

<!-- ## Environmental variables for creating certificate of Tomcat service
```
EMAIL=admin@email.com
FQDN=a.com
```

## Issuer for staging
```
cat <<EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: istio-system
spec:
  acme:
    email: ${EMAIL}
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: example-issuer-account-key
    http01: {}
---
EOF
```

## Issuer status, expecting to see Status: True and Type: Ready
```kubectl describe issuer/letsencrypt-staging -n istio-system```

## Generating certificate
```
cat <<EOF | kubectl apply -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: tomcat-certificate
  namespace: istio-system
spec:
  secretName: tomcat-certificate
  issuerRef:
    name: letsencrypt-staging
  commonName: ${FQDN}
  dnsNames:
  - ${FQDN}
  acme:
    config:
    - http01:
        ingressClass: istio
      domains:
      - ${FQDN}
---
EOF
```

## status should turn to True from False in a few seconds or minutes
```kubectl describe certificate/tomcat-certificate -n istio-system```

##  -->

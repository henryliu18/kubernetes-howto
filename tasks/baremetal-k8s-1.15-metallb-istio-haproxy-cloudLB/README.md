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
* Container deployment (Nginx)
* Selfsigning certificate and private key using openssl

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
  podSubnet: 10.244.0.0/16" | sudo tee -a /tmp/kubeadm.yaml && \
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > ~/k8s.log && \
sleep 30 && \

#how a regular user access kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

#Deploy Pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && \

#alias
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
alias gettoken='kubectl describe -n kube-system secret/'
alias c='cat <<EOF | kubectl apply -f -'" >> ~/.bash_profile
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
helm repo add istio.io https://storage.googleapis.com/istio-release/releases/1.3.3/charts/
helm repo update
helm install istio.io/istio-init --name istio-init --namespace istio-system
```

## Create Kiali secret (optional)
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $(echo -n istio-system)
  labels:
    app: kiali
type: Opaque
data:
  username: $(echo -n admin | base64)
  passphrase: $(echo -n pass | base64)
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
       --set certmanager.email=admin@corp.com \
       --set grafana.enabled=True \
       --set kiali.enabled=True
```

## Tomcat and Nginx server deployment on default namespace with istio-injection
```
kubectl label ns default istio-injection=enabled && \

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
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  type: ClusterIP
EOF
```

## Gateway istio-autogenerated-k8s-ingress is created by default
* Accepting any header host for http/https protocol ingress control
* To restrict incoming request header host, specifying "example.com" to Hosts in yaml

```kubectl describe gateway/istio-autogenerated-k8s-ingress -n istio-system```

## Create Istio virtualservice for Tomcat service
* hosts "tom.busyapi.com" routes requests with specified host to destination service tomcat-service
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
  - "tom.busyapi.com"
  gateways:
  - istio-system/istio-autogenerated-k8s-ingress
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

## Create Istio virtualservice for Nginx service
* hosts "*" routes requests with any/none host specified to destination service nginx-service
* uri prefix "/" accepts any request that beginning with "/"
* route defines which service and port to send request to

```
cat <<EOF | kubectl apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: nginx-vs
spec:
  hosts:
  - "*"
  gateways:
  - istio-system/istio-autogenerated-k8s-ingress
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: nginx-service
        port:
          number: 80
---
EOF
```

## Testing metallb endpoint of Tomcat service
```curl http://10.244.1.220/ -HHost:tom.busyapi.com```

## Testing metallb endpoint of Nginx service (with no host header specified)
```curl http://10.244.1.220/```

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
```curl http://10.244.1.220/ -HHost:tom.busyapi.com```

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
#    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server application is up and healty - 200 status code
    server node1 10.244.1.220:80 check
' | sudo tee -a /etc/haproxy/haproxy.cfg && \
sudo systemctl start haproxy && \
sudo systemctl enable haproxy
```

## Testing haproxy endpoint of Tomcat service from haproxy node, this request is proceeded through haproxy service
```curl http://localhost/ -HHost:tom.busyapi.com```

## Testing haproxy endpoint of Tomcat service from public ip
```http://<haproxy-node1-ip>/```
* At this point if you set up DNS A record tom.busyapi.com pointing to haproxy-node1-ip then host header will be passed to haproxy when you navigate tom.busyapi.com in your browser, consequently host header will be passed to istiogateway ingress control -> virtualservice and finally route to tomcat-service to process

# (Optional) Cloud provider managed load balancer for serving all haproxy endpoints for Tomcat service
* Selecing all haproxy VMs for backends
* Backend port is 80 (metallb load balancer servicing port)
* Frontend Listener port is 80 for ingress traffic

## Testing managed load balancer endpoint of Tomcat service
```http://<cloud-load-balancer-public-ip>/```

## Set up DNS A record for tom.busyapi.com -> cloud-load-balancer-public-ip and test it
```http://tom.busyapi.com/```

## Enabling SSL for testing, you will need to create your own CA and Private key

* Generate the private key of the root CA

```openssl genrsa -out rootCAKey.pem 2048```

* Generate the self-signed root CA certificate

```openssl req -x509 -sha256 -new -nodes -key rootCAKey.pem -days 3650 -out rootCACert.pem```

* rootCACert.pem for CA and SSL certificate and rootCAKey.pem for private key to create certificate for cloud LB listener
```
ls -l
total 8
-rw-r--r-- 1 root root 1391 Oct 18 05:02 rootCACert.pem
-rw-r--r-- 1 root root 1675 Oct 18 05:01 rootCAKey.pem
```

* Create a new Listener for HTTPS requests using certificate created above

## Testing of SSL enabled tom.busyapi.com, -k allows curl to perform "insecure" SSL connections and transfers.
```curl -k https://tom.busyapi.com/```

## Expose Kiali (optional), modify from type: ClusterIP to type: LoadBalancer or NodePort
```kubectl edit svc kiali -n istio-system```

## Find out exposed endpoint and access Kiali console from browser
```
kubectl get pod -o wide -n istio-system | grep kiali
kiali-7f84b859d7-rwf4h                   1/1     Running     3          20h     10.244.1.65   worker1   <none>           <none>

kubectl get svc kiali -n istio-system
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)           AGE
kiali   LoadBalancer   10.101.233.246   10.244.1.221   20001:31983/TCP   19h

http://public-ip-of-worker1:31983/kiali/
```

## Clean up
* delete demo containers
```
kubectl delete vs/nginx-vs
kubectl delete vs/tomcat-vs
kubectl delete svc/tomcat-service
kubectl delete svc/nginx-service
kubectl delete deployment/nginx-demo
kubectl delete deployment/tomcat-demo
```
* unlabel default namespace istio-injection

```kubectl label ns default istio-injection-```

* delete Kiali secret

```kubectl delete Secret/kiali -n istio-system```

* delete istio
```
helm del istio --purge
helm del istio-init --purge
kubectl delete ns/istio-system
helm repo remove istio.io
helm repo update
```

* delete CRDs for cert-manager

```kubectl delete -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.7/deploy/manifests/00-crds.yaml```

* delete metallb
```
kubectl delete ConfigMap/metallb-config -n metallb-system
helm del metallb --purge
```

* delete helm
```
kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller
kubectl -n kube-system delete serviceaccount tiller
kubectl -n kube-system delete svc tiller-deploy

rm -rf .helm/
sudo rm -rf linux-amd64/
sudo rm helm-v2.14.1-linux-amd64.tar.gz
```

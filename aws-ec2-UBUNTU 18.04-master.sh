#!/bin/bash

#KUBERNETES MASTER NODE BUILD FOR AWS EC2 UBUNTU 18.04 LTS

#BEGIN
int_ip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
int_hostname=`hostname`
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
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > /home/ubuntu/k8sinit.log && \
mkdir -p /home/ubuntu/.kube && \
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config && \
sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config && \
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

#Install helm
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
sudo helm init --service-account tiller --skip-refresh && \
sleep 30 && \

#Deploy Nginx Ingress
#Make master node edge point which will be Nginx Ingress endpoint
sudo kubectl label node ${int_hostname} node-role.kubernetes.io/edge= && \
echo -e "controller:
  replicaCount: 1
  hostNetwork: true
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
            - key: component
              operator: In
              values:
              - controller
          topologyKey: kubernetes.io/hostname
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
defaultBackend:
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule" | tee -a /tmp/ingress-nginx.yaml && \
sudo helm repo update && \
sudo helm install stable/nginx-ingress \
-n nginx-ingress \
--namespace ingress-nginx  \
-f /tmp/ingress-nginx.yaml && \
sleep 30 && \

#Deploy Dashboard by helm
echo -e "image:
  repository: k8s.gcr.io/kubernetes-dashboard-amd64
  tag: v1.10.1
ingress:
  enabled: true
  hosts: 
    - dashboard.yourdomain.com
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: \"true\"
    nginx.ingress.kubernetes.io/backend-protocol: \"HTTPS\"
  tls:
    - secretName: dashboard-yourdomain-com-tls-secret
      hosts:
      - dashboard.yourdomain.com
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
rbac:
  clusterAdminRole: true" | tee -a /tmp/kubernetes-dashboard.yaml && \
sudo helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f /tmp/kubernetes-dashboard.yaml

#Demo using Nginx Ingress (LoadBalancer) redirects traffic of specific url to pod (in this case a Tomcat pod)
kubectl run tomcat --generator=run-pod/v1 --image=tomcat:alpine --port=8080 --replicas=1 && \
kubectl expose pod tomcat --type=ClusterIP --name=tomcat-server && \
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tomcat-ingress
spec:
  tls:
  - hosts:
    - tom.yourdomain.com
    secretName: tom-yourdomain-secret
  rules:
  - host: tom.yourdomain.com
    http:
      paths:
      - path: /
        backend:
          serviceName: tomcat-server
          servicePort: 8080" | tee -a /tmp/tomcat-ingress.yaml && \
kubectl apply -f /tmp/tomcat-ingress.yaml && \
echo 'First, change dns of tom.yourdomain.com to edge node public IP, tomcat-ingress is now
created, when you navigate to https://tom.yourdomain.com tomcat-ingress will redirect your
https request to tomcat pod via the service tomcat-server'
echo 'Kubernetes-dashboard is also exposed via Ingress'
echo 'How to get Dashboard token?'
echo 'kubectl describe -n kube-system secret/$(kubectl -n kube-system get secret | grep kubernetes-dashboard-token|cut -d" " -f1)'
#END

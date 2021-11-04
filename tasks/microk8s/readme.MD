# microk8s on ARM64
#### Lightweight upstream Kubernetes
#### No APIs added or removed
#### MicroK8s is small, with sensible defaults that ‘just work’. A quick install, easy upgrades and great security make it perfect for micro clouds and edge computing.

### Disable firewalld ufw..
```bash
sudo apt update
sudo apt install firewalld
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

sudo systemctl stop ufw
sudo systemctl disable ufw
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### Install microk8s
```bash
sudo snap install microk8s --classic
```

### add user to microk8s group
```bash
sudo usermod -a -G microk8s ubuntu
sudo chown -f -R ubuntu ~/.kube
newgrp microk8s
```

### check microk8s status
```bash
microk8s status --wait-ready
```

### enable addons
```bash
microk8s enable helm3
microk8s enable dns
microk8s enable metallb
- 10.0.0.240-10.0.0.250
microk8s enable ingress
```

### create service for ingress
```bash
cat <<EOF | microk8s kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: ingress
  namespace: ingress
spec:
  selector:
    name: nginx-ingress-microk8s
  type: LoadBalancer
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 443
EOF
```

### Tomcat webapp with ingress -> tomcat.example.com
```bash
cat <<EOF | microk8s kubectl apply -f -
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
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: tomcat
  type: ClusterIP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-tomcat
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "public"
spec:
  rules:
  - host: tomcat.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tomcat-service
            port:
              number: 80
EOF
```

### Cert-manager
```bash
microk8s helm3 repo add  jetstack https://charts.jetstack.io
microk8s helm3 repo update
microk8s helm3 install   cert-manager jetstack/cert-manager   --namespace cert-manager   --create-namespace   --version v1.5.4   --set installCRDs=true
```

### Kubeseal
```bash
# Kubeseal on cluster
microk8s helm3 repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
microk8s helm3 repo update
microk8s helm3 install sealed-secrets sealed-secrets/sealed-secrets --set namespace=kube-system

# kubeseal on client
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-arm64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
rm kubeseal

# specify the controller name of sealed-mysecret, test if cert can be fetched
export KUBECONFIG=/var/snap/microk8s/current/credentials/client.config
kubeseal --fetch-cert --controller-name=sealed-secrets

# test seal/unseal secret
echo -n bar | microk8s kubectl create secret generic mysecret --dry-run --from-file=foo=/dev/stdin -o yaml >mysecret.yaml
kubeseal --controller-name=sealed-secrets <mysecret.yaml >sealed-mysecret.yaml -o yaml
microk8s kubectl create -f sealed-mysecret.yaml
microk8s kubectl get secret mysecret -o yaml

# delete sealed-mysecret
microk8s kubectl delete -f sealed-mysecret.yaml
microk8s kubectl get secret mysecret -o yaml
```

### Argo CD...not working due to image not correctly built...

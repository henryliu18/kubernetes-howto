# MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

## First identify K8s cluster pod subnet cidr, cidr gives you the available subnet ip range so you can allocate valid ip address from the range to metallb
```kubectl cluster-info dump|grep cidr```
## Create a namespace
```kubectl create ns metallb-system```
## With manifest
```https://metallb.universe.tf/installation/#installation-by-manifest```
## With helm
```
helm repo add metallb https://metallb.github.io/metallb
helm install metallb metallb/metallb --namespace metallb-system
```
## Configuration
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.244.1.220-10.244.1.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF
```
## Tomcat deployment using LoadBalancer
```yaml
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
  - port: 80
    protocol: TCP
    targetPort: 8080
  selector:
    run: tomcat
  type: LoadBalancer
EOF
```

## Clean up
```bash
kubectl delete -f "manifest from the installation url"
kubectl delete ns metallb-system
```
```bash
helm uninstall metallb --namespace metallb-system
kubectl delete ns metallb-system
```

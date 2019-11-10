# MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.

## First identify K8s cluster pod subnet cidr, cidr gives you the available subnet ip range so you can allocate valid ip address from the range to metallb
```kubectl cluster-info dump|grep cidr```

## With helm (preferable)
```helm install --name metallb stable/metallb --namespace metallb-system```
## By default, the helm chart looks for MetalLB configuration in the metallb-config ConfigMap
```yaml
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
## https://metallb.universe.tf/installation/
```kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml```

## https://metallb.universe.tf/configuration/#layer-2-configuration
```yaml
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.244.1.220-10.244.1.250              #gives MetalLB control over cluster IP range
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

## Environment Requirements
```
Public ip for istio-ingressgateway -> GCP Load balancing service
GKE 1.14.6-gke-13
    2 node
    2 vCPU
    7.5 GB memroy
    100 GB disk
```

## Required components
```
GKE 1.14.6-gke-13
helm
    istio-init
    istio
    cert-manager
```

## helm installation
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

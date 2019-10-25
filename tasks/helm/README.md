# The package manager for Kubernetes

## helm 2.14.3 binaries
```
sudo curl -O https://get.helm.sh/helm-v2.14.3-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v2.14.3-linux-amd64.tar.gz && \
sudo cp linux-amd64/helm /usr/local/bin/
```
## ServiceAccount and ClusterRoleBinding
```
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
```
## helm init
```helm init --service-account tiller --skip-refresh```
* if you get errors, run below workaround

```
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
helm init --service-account tiller --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | sed 's@  replicas: 1@  replicas: 1\n  selector: {"matchLabels": {"app": "helm", "name": "tiller"}}@' | kubectl apply -f -
```

## repo update
```helm repo update```

## Clean up
```
kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller
kubectl -n kube-system delete serviceaccount tiller
kubectl -n kube-system delete svc tiller-deploy
```

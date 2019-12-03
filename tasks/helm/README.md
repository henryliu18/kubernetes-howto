# The package manager for Kubernetes

## helm 3.0.0 binaries
```bash
sudo curl -O https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v3.0.0-linux-amd64.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/helm
```
~~## ServiceAccount and ClusterRoleBinding~~
```yaml
~~cat <<EOF | kubectl create -f -~~
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
```bash
helm init --service-account tiller --skip-refresh
# if you get errors, run below workaround
helm init --service-account tiller --override spec.selector.matchLabels.'name'='tiller',spec.selector.matchLabels.'app'='helm' --output yaml | sed 's@apiVersion: extensions/v1beta1@apiVersion: apps/v1@' | kubectl apply -f -
```

## repo update
```helm repo update```

## Clean up
```bash
kubectl -n kube-system delete deployment tiller-deploy
kubectl delete clusterrolebinding tiller
kubectl -n kube-system delete serviceaccount tiller
kubectl -n kube-system delete svc tiller-deploy
```

# The package manager for Kubernetes

## helm 3.0.0 binaries
```bash
sudo curl -O https://get.helm.sh/helm-v3.0.0-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v3.0.0-linux-amd64.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/helm
```
~~## ServiceAccount and ClusterRoleBinding~~

~~## helm init~~

## repo update
```helm repo update```

## Clean up
```bash
sudo rm -f /usr/local/bin/helm && \
sudo rm -rf linux-amd64/
```

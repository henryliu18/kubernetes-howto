# The package manager for Kubernetes

## install helm 3.7.0 binaries on control plane node
```bash
sudo curl -O  https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz && \
sudo tar -zxvf helm-v3.7.0-linux-amd64.tar.gz && \
sudo mv linux-amd64/helm /usr/local/bin/helm && \
helm repo add stable https://charts.helm.sh/stable && \
sudo rm -rf linux-amd64/ && \
sudo rm -f helm-v3.7.0-linux-amd64.tar.gz
```
## repo update
```bash
helm repo update
```
## Clean up
```bash
sudo rm -f /usr/local/bin/helm
```

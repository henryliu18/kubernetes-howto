# The package manager for Kubernetes

## install helm 3.7.1 binaries on control plane node
```bash
arch=$(uname -m)
if [[ $arch == x86_64* ]]; then
    sudo curl -O  https://get.helm.sh/helm-v3.7.1-linux-amd64.tar.gz && \
    sudo tar -zxvf helm-v3.7.1-linux-amd64.tar.gz && \
    sudo mv -f linux-amd64/helm /usr/local/bin/helm && \
    helm repo add stable https://charts.helm.sh/stable && \
    sudo rm -rf linux-amd64/ && \
    sudo rm -f helm-v3.7.1-linux-amd64.tar.gz
elif [[ $arch == i*86 ]]; then
    sudo curl -O  https://get.helm.sh/helm-v3.7.1-linux-386.tar.gz && \
    sudo tar -zxvf helm-v3.7.1-linux-386.tar.gz && \
    sudo mv -f linux-386/helm /usr/local/bin/helm && \
    helm repo add stable https://charts.helm.sh/stable && \
    sudo rm -rf linux-386/ && \
    sudo rm -f helm-v3.7.1-linux-386.tar.gz
elif  [[ $arch == arm* ]]; then
    sudo curl -O  https://get.helm.sh/helm-v3.7.1-linux-arm.tar.gz && \
    sudo tar -zxvf helm-v3.7.1-linux-arm.tar.gz && \
    sudo mv -f linux-arm/helm /usr/local/bin/helm && \
    helm repo add stable https://charts.helm.sh/stable && \
    sudo rm -rf linux-arm/ && \
    sudo rm -f helm-v3.7.1-linux-arm.tar.gz
elif  [[ $arch == aarch64 ]]; then
    sudo curl -O  https://get.helm.sh/helm-v3.7.1-linux-arm64.tar.gz && \
    sudo tar -zxvf helm-v3.7.1-linux-arm64.tar.gz && \
    sudo mv -f linux-arm64/helm /usr/local/bin/helm && \
    helm repo add stable https://charts.helm.sh/stable && \
    sudo rm -rf linux-arm64/ && \
    sudo rm -f helm-v3.7.1-linux-arm64.tar.gz
fi
```
## repo update
```bash
helm repo update
```
## Clean up
```bash
sudo rm -f /usr/local/bin/helm
```

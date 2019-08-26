# you can interact with k8s cluster via any user (root or non-root), perform below steps to configure necessary tools for your account

# kubectl
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
# helm
```
helm init --service-account tiller --skip-refresh
helm repo update
```

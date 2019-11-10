# init k8s cluster, pod network
```yaml
echo -e "apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: $(hostname -I | awk -F ' ' '{print $1}')
  bindPort: 6443
nodeRegistration:
  taints:
  - effect: PreferNoSchedule
    key: node-role.kubernetes.io/master
---
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.16.2
networking:
  podSubnet: 10.244.0.0/16" | sudo tee /tmp/kubeadm.yaml && \
```

```bash
sudo kubeadm init --config /tmp/kubeadm.yaml --ignore-preflight-errors=NumCPU > ~/k8s.log && \
sleep 30 && \

#how a regular user access kubectl
mkdir -p $HOME/.kube && \
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
sudo chown $(id -u):$(id -g) $HOME/.kube/config && \

#Deploy Pod network
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml && \
if ! grep -q kpod ~/.bashrc ; then
  echo -e "
alias k='kubectl'
alias kdep='kubectl get deployment -o wide --all-namespaces'
alias kpod='kubectl get pod -o wide --all-namespaces'
alias ksvc='kubectl get svc -o wide --all-namespaces'
alias king='kubectl get ingress --all-namespaces'
alias knod='kubectl get node -o wide'
alias klog='kubectl logs'
alias kexe='kubectl exec'
alias kdel='kubectl delete'
alias kwatch='watch kubectl get node,deployment,pod,svc,ing,pv,pvc,sc,sts,job -o wide'
alias c='cat <<EOF | kubectl apply -f -'" >> ~/.bashrc
fi
```

# Create .kube and copy config file run as non-root user
```bash
mkdir ~/.kube
sudo cp /etc/kubernetes/admin.conf ~/.kube/config
sudo chown azureuser:azureuser ~/.kube/config
```

# Test cluster access
```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -n kube-system
```

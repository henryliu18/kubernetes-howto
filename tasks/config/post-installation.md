# Create .kube and copy config file run as non-root user on control plane host
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

# Expected output, noting that all pods' status should be 'running'
```bash
azureuser@node1:~$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:6443

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

azureuser@node1:~$ kubectl get nodes
NAME    STATUS   ROLES                  AGE     VERSION
node1   Ready    control-plane,master   2m32s   v1.22.2
node2   Ready    <none>                 94s     v1.22.2

azureuser@node1:~$ kubectl get pods -n kube-system
NAME                              READY   STATUS    RESTARTS   AGE
coredns-8474476ff8-tfp2v          1/1     Running   0          50s
coredns-8474476ff8-xmlbc          1/1     Running   0          53s
dns-autoscaler-5ffdc7f89d-8lntr   1/1     Running   0          51s
kube-apiserver-node1              1/1     Running   0          2m26s
kube-controller-manager-node1     1/1     Running   1          2m26s
kube-flannel-84htt                1/1     Running   0          72s
kube-flannel-pkhbd                1/1     Running   0          72s
kube-proxy-blmmr                  1/1     Running   0          93s
kube-proxy-fh7zx                  1/1     Running   0          93s
kube-scheduler-node1              1/1     Running   1          2m26s
nginx-proxy-node2                 1/1     Running   0          95s
nodelocaldns-2ggkb                1/1     Running   0          50s
nodelocaldns-h5d6l                1/1     Running   0          50s

```

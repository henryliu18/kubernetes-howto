# K3s

### firewalld on all nodes
```bash
sudo apt update
sudo apt install firewalld
sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp
sudo firewall-cmd --zone=public --permanent --add-port=80/tcp
sudo firewall-cmd --zone=public --permanent --add-port=443/tcp
sudo firewall-cmd --reload

sudo systemctl stop ufw
sudo systemctl disable ufw
sudo systemctl stop firewalld
sudo systemctl disable firewalld
```

### install k3s server without traefix, local-storage and metrics-server
```bash
sudo curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable=traefik,local-storage,metrics-server
```

### k3s status
```bash
sudo systemctl status k3s
```

### token for agent to join server cluster
```bash
sudo cat /var/lib/rancher/k3s/server/token
```

### agent node join server
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.47:6443 K3S_TOKEN=<TOKEN> sh -
```

### helm won't work without KUBECONFIG
```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
```
### source .bashrc
```bash
source ~/.bashrc
```

### [install helm](https://github.com/henryliu18/kubernetes-howto/blob/master/tasks/helm/README.md)

### [install ingress-nginx](https://github.com/henryliu18/kubernetes-howto/blob/master/tasks/ingress-controller/ingress-nginx.md)

### Uninstall server node
```bash
sudo /usr/local/bin/k3s-uninstall.sh
```
### Uninstall agent node
```bash
sudo /usr/local/bin/k3s-agent-uninstall.sh
```

#K3s

### install k3s server without traefix, local-storage and metrics-server
```bash
sudo curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable=traefik,local-storage,metrics-server
```

###k3s status
```bash
sudo systemctl status k3s
```

###token for agent to join server cluster
```bash
sudo cat /var/lib/rancher/k3s/server/token
```

###agent node join server
```bash
curl -sfL https://get.k3s.io | K3S_URL=https://192.168.0.47:6443 K3S_TOKEN=K10ae1d191c8b7684d33634ab4427f26a68dc56b3d65ccfaf04f04734b625e0919d::server:1ed1f8d01cc0396c0f8e2e4c2e72bc94 sh -
```

###MUST
```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
```

### Uninstall server node
```bash
sudo /usr/local/bin/k3s-uninstall.sh
```
### Uninstall agent node
```bash
sudo /usr/local/bin/k3s-agent-uninstall.sh
```

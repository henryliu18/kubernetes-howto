# Add helm repo
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
```

# (optional) dump all default values to ingress-nginx.yaml for custom installation
```bash
helm show values ingress-nginx/ingress-nginx > ingress-nginx.yaml
helm install myingress ingress-nginx/ingress-nginx --values ingress-nginx.yaml
```

# Install
```bash
helm install myingress ingress-nginx/ingress-nginx --set controller.kind=DaemonSet
```

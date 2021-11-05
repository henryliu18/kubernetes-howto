
## In order to create your free SSL certificate, below requirements need to be fulfilled.
- Your webapp is servicing port 80
- Your webapp is internet facing
- You own a domain name
- You are able to perform dns changes and/or have access to the web server

### [SSLForFree](https://www.sslforfree.com/)

### Cert files created, what are they
A zip file that's created by the CA will be sent to you, extract it and you will get 3 important files, they are
- Certificate (Public key) e.g. ```site.crt```
- Private key e.g. ```site.key```
- Intermediate certificate of the CA e.g. ```ca_bundle.crt```

### Create tls secret
1. Put site certificate and intermediate certificate into 1 certificate file e.g. ```full.crt```
```bash
cat site.crt ca_bundle.crt > full.crt
```
2. Create tls secret
```bash
kubectl create secret tls tls-site-example-com \
--key site.key \
--cert full.crt
```

### Point ingress of the site to tls-site-example-com
```bash
kubectl edit ingress ingress-site-example
```
Add tls to ingress and save
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: public
  name: ingress-site-example
  namespace: default
spec:
  rules:
  - host: site.example.com
    http:
      paths:
      - backend:
          service:
            name: site-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - site.example.com
    secretName: tls-site-example-com
```

### Testing
curl https://site.example.com

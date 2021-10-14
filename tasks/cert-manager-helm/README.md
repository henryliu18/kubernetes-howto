# cert-manager
##### adds certificates and certificate issuers as resource types in Kubernetes clusters, and simplifies the process of obtaining, renewing and using those certificates.
##### It can issue certificates from a variety of supported sources, including Let’s Encrypt, HashiCorp Vault, and Venafi as well as private PKI.
![image](https://cert-manager.io/images/high-level-overview.svg)

#### High level speaking, we will create Issuer (let's encrypt API) for handling Certificate request for our website, since we're using ingress controller, we will be updating the corresponding Ingress of the website with Issuer and issued Certificate from the issuer.  These are 2 stages of getting certificated - staging and prod, a real certificate can not be issued before staging one was successfully issued.

## Before we go.. make sure your load balancer is pointing to your ingress controller, and your application is deployed and resolvable by ingress controller.  Also it is publicly accessible.
```bash
curl http://nginx.example.com
curl -k https://nginx.example.com
```

## Install cert-manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.4/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.5.4
```

## Create Issuer (let's encrypt) for staging and prod.  Change your@email.com to your email
```yaml
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-staging
  namespace: default
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: your@email.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-staging
    # Enable the HTTP-01 challenge provider
    solvers:
    # An empty 'selector' means that this solver matches all domains
    - selector: {}
      http01:
        ingress:
          class: nginx
---
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-prod
  namespace: default
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: your@email.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    solvers:
    # An empty 'selector' means that this solver matches all domains
    - selector: {}
      http01:
        ingress:
          class: nginx
```

## Verify Issuer status
```bash
kubectl describe issuer.cert-manager.io/letsencrypt-staging
kubectl describe issuer.cert-manager.io/letsencrypt-prod
```

### Expected output
```bash
Status:
  Acme:
    Last Registered Email:  your@email.com
    Uri:                    https://acme-staging-v02.api.letsencrypt.org/acme/acct/29944978
  Conditions:
    Last Transition Time:  2021-10-13T11:53:45Z
    Message:               The ACME account was registered with the ACME server
    Observed Generation:   1
    Reason:                ACMEAccountRegistered
    Status:                True
    Type:                  Ready
Events:                    <none>
```

## Create Certificate for staging (This step will create a Certificate and Secret.  The Secret will later be used to update Ingress of the site
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-example-com
  namespace: default
spec:
  secretName: nginx-example-com-tls-staging
  issuerRef:
    name: letsencrypt-staging
  commonName: nginx.example.com
  dnsNames:
  - nginx.example.com
```

### Verify Certificate status
```bash
kubectl describe certificate.cert-manager.io/nginx-example-com
```

### Expected output
```bash
Events:
  Type    Reason     Age   From          Message
  ----    ------     ----  ----          -------
  Normal  Issuing    42s   cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  42s   cert-manager  Stored new private key in temporary Secret resource "nginx-example-com-czvbj"
  Normal  Requested  42s   cert-manager  Created new CertificateRequest resource "nginx-example-com-b42qq"
  Normal  Issuing    11s   cert-manager  The certificate has been successfully issued
```

## Update Certificate secret in Ingress for staging
```bash
kubectl get ingress
```
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
```
```yaml
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-staging
```
```
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - backend:
          service:
            name: nginx-service
            port:
              number: 80
        path: /
        pathType: Prefix
```
```yaml
  tls:
  - hosts:
    - nginx.example.com
    secretName: nginx-example-com-tls-staging
```

## Verify Ingress for staging
```bash
kubectl describe ingress.networking.k8s.io/ingress-nginx
```

### Expected output
```bash
Events:
  Type    Reason             Age                From                      Message
  ----    ------             ----               ----                      -------
  Normal  CreateCertificate  22s                cert-manager              Successfully created Certificate "nginx-example-com-tls-staging"
```

## Testing staging
```bash
wget --save-headers -O- nginx.example.com
```

## Create Certificate for prod (This step will create a Certificate and Secret.  The Secret will later be used to update Ingress of the site
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: nginx-example-com
  namespace: default
spec:
  secretName: nginx-example-com-tls-prod
  issuerRef:
    name: letsencrypt-prod
  commonName: nginx.example.com
  dnsNames:
  - nginx.example.com
```
### Verify Certificate status
```bash
kubectl describe certificate.cert-manager.io/nginx-example-com
```
### Expected output
```bash
Events:
  Type    Reason     Age                 From          Message
  ----    ------     ----                ----          -------
  Normal  Generated  7m5s                cert-manager  Stored new private key in temporary Secret resource "nginx-example-com-czvbj"
  Normal  Requested  7m5s                cert-manager  Created new CertificateRequest resource "nginx-example-com-b42qq"
  Normal  Issuing    6m34s               cert-manager  The certificate has been successfully issued
  Normal  Issuing    99s (x2 over 7m5s)  cert-manager  Issuing certificate as Secret does not exist
  Normal  Generated  99s                 cert-manager  Stored new private key in temporary Secret resource "nginx-example-com-qd9wd"
  Normal  Requested  99s                 cert-manager  Created new CertificateRequest resource "nginx-example-com-l2dtj"
  Normal  Issuing    29s (x2 over 15m)   cert-manager  The certificate has been successfully issued
```

## Update Certificate secret in Ingress for prod
```bash
kubectl get ingress
```
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
```
```yaml
    cert-manager.io/cluster-issuer: letsencrypt-prod
```
```
    kubernetes.io/ingress.class: nginx
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - backend:
          service:
            name: nginx-service
            port:
              number: 80
        path: /
        pathType: Prefix
  tls:
  - hosts:
    - nginx.example.com
```
```yaml
    secretName: nginx-example-com-tls-prod
```
## Verify Ingress for prod
```bash
kubectl describe ingress.networking.k8s.io/ingress-nginx
```

### Expected output
```bash
Events:
  Type    Reason             Age                 From                      Message
  ----    ------             ----                ----                      -------
  Normal  CreateCertificate  17m                 cert-manager              Successfully created Certificate "nginx-example-com-tls-staging"
  Normal  Sync               2m6s (x3 over 31m)  nginx-ingress-controller  Scheduled for sync
  Normal  Sync               2m6s (x3 over 31m)  nginx-ingress-controller  Scheduled for sync
  Normal  CreateCertificate  2m6s                cert-manager              Successfully created Certificate "nginx-example-com-tls-prod"
  Normal  DeleteCertificate  2m6s                cert-manager              Successfully deleted unrequired Certificate "nginx-example-com-tls-staging"
```
## Testing prod
```bash
curl https://nginx.example.com
```

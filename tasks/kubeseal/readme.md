# Kubeseal for GitOps

## kubeseal to encrypt secret -> push sealedsecret to repo -> CD tools pick up the change to create sealedsecret -> sealed secret controller kicks in to create secret using decrypted content

### Installation client
```bash
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64 -O kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

### Installation controller
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/controller.yaml
```

### Verify Pod logs of the sealed secrets controller
```bash
kubectl logs $(kubectl get pods --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' -n kube-system -l name=sealed-secrets-controller) -n kube-system
```

### you can also fetch the cert for offline mode
```bash
kubeseal --fetch-cert
```

### [create your own cert/private key for TLS](https://github.com/bitnami-labs/sealed-secrets/blob/main/docs/bring-your-own-certificates.md)

### Create a secret
```bash
echo -n bar | kubectl create secret generic mysecret --dry-run --from-file=foo=/dev/stdin -o yaml >mysecret.yaml
```

### Encryption
```bash
kubeseal  <mysecret.yaml >mysealedsecret.yaml -o yaml

### create sealedsecret
kubectl create -f mysealedsecret.yaml

### get both encrypted and decrypted secrets
kubectl get sealedsecret,secret mysecret
kubectl get secret/mysecret -o yaml
```

### update secret trick
```bash
# encrypt barbar, secret name is needed as an input
echo -n barbar | kubeseal --raw --name=mysecret --from-file=/dev/stdin

# specify cert if needed
echo -n barbar | kubeseal --cert=public-key-cert.pem --raw --name=mysecret --from-file=/dev/stdin

# update sealedsecret yaml with encrypted string
vi mysealedsecret.yaml

# replace sealedsecret
kubectl replace -f mysealedsecret.yaml

# check mysecret again
kubectl get secret/mysecret -o yaml
```

### delete sealedsecret and check the secret
```bash
kubectl delete sealedsecret/mysecret
kubectl get sealedsecret,secret mysecret
```

### Uninstall
```bash
kubectl delete -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/controller.yaml
```

### Backup TLS (Delete pod everytime when you destroy or create TLS for pod to pick it up new TLS)
```bash
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key=active
kubectl get secret <TLS-SECRET-NAME> -n kube-system -o yaml
```

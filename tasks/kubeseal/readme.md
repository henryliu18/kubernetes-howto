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
echo -n bar | kubectl create secret generic mysecret --dry-run --from-file=foo=/dev/stdin -o json >mysecret.json
```

### seal it
```bash
kubeseal  <mysecret.json >mysealedsecret.json
```

### create sealedsecret
```bash
kubectl create -f mysealedsecret.json
```

### get both encrypted and decrypted secrets
```bash
kubectl get sealedsecret,secret mysecret
kubectl get secret/mysecret -o yaml
```

### delete sealedsecret and check the secret
```bash
kubectl delete sealedsecret/mysecret
kubectl get sealedsecret,secret mysecret
```

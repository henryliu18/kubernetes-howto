# Install cert-manager
```
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
sudo helm repo add jetstack https://charts.jetstack.io
sudo helm repo update
sudo helm install --name cert-manager --namespace kube-system jetstack/cert-manager --version v0.8.0
```
# Need your email address and domain name for Staging clusterissuer
```
unset your_email_address
until [ "${your_email_address}" != '' ]; do
        echo 'enter your email address:'
        read your_email_address
done
unset fqdn
until [ "${fqdn}" != '' ]; do
        echo 'enter your domain name:'
        read fqdn
done
```
# Staging issuer
```
cat <<EOF | kubectl create -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
 name: letsencrypt-staging
spec:
 acme:
   # The ACME server URL
   server: https://acme-staging-v02.api.letsencrypt.org/directory
   # Email address used for ACME registration
   email: ${your_email_address}
   # Name of a secret used to store the ACME account private key
   privateKeySecretRef:
     name: letsencrypt-staging
   # Enable the HTTP-01 challenge provider
   http01: {}
EOF
```
# Apply staging issuer to an ingress
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations:                                             #new line added
    kubernetes.io/ingress.class: nginx                     #new line added
    certmanager.k8s.io/cluster-issuer: letsencrypt-staging #new line added
spec:
  tls:
  - hosts:
    - ${fqdn}
    secretName: letsencrypt-staging                        #new line added
  rules:
  - host: ${fqdn}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80
EOF
```
# Verify staging ingress and cert status
```kubectl describe ingress```
```kubectl describe certificate```
# Prod issuer
```
cat <<EOF | kubectl create -f -
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${your_email_address}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-prod
    # Enable the HTTP-01 challenge provider
    http01: {}
EOF
```
# Apply prod issuer to an ingress
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod   #modify from letsencrypt-staging to letsencrypt-prod
spec:
  tls:
  - hosts:
    - ${fqdn}
    secretName: letsencrypt-prod                          #modify from letsencrypt-staging to letsencrypt-prod
  rules:
  - host: ${fqdn}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80
EOF
```
# Verification
```kubectl describe ingress kube-test-container-ingress```
```kubectl describe certificate letsencrypt-prod```

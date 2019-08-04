#!/bin/bash

#KUBERNETES Installing and Configuring Cert-Manager
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
your_email_address=''
until [ "${your_email_address}" != '' ]; do
        echo 'enter your email address:'
        read your_email_address
done
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter your domain name:'
        read yourdomain
done
#Step 2: create the cert-manager Custom Resource Definitions (CRDs)
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
sudo helm repo add jetstack https://charts.jetstack.io
sudo helm repo update
sudo helm install --name cert-manager --namespace kube-system jetstack/cert-manager --version v0.8.0
#Staging issuer
echo -e "apiVersion: certmanager.k8s.io/v1alpha1
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
" | tee -a staging_issuer.yaml
kubectl create -f staging_issuer.yaml
#Reapply Ingress yaml for staging
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations: #add
    kubernetes.io/ingress.class: nginx #add
    certmanager.k8s.io/cluster-issuer: letsencrypt-staging #add
spec:
  tls:
  - hosts:
    - test.${yourdomain}
    secretName: letsencrypt-staging #add
  rules:
  - host: test.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80" | tee -a kube-test-container-ingress-stg.yaml
kubectl apply -f kube-test-container-ingress-stg.yaml
#Verify staging ingress and cert status
kubectl describe ingress     #Normal  UpdateCertificate  7s                cert-manager              Successfully updated Certificate "letsencrypt-staging"
kubectl describe certificate #Certificate issued successfully
#Prod issuer
echo -e "apiVersion: certmanager.k8s.io/v1alpha1
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
" | tee -a prod_issuer.yaml
kubectl create -f prod_issuer.yaml
#Reapply Ingress yaml for prod
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - test.${yourdomain}
    secretName: letsencrypt-prod
  rules:
  - host: test.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80" | tee -a kube-test-container-ingress-prod.yaml
kubectl apply -f kube-test-container-ingress-prod.yaml
#END

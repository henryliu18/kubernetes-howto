#!/bin/bash

#KUBERNETES PROD CLUSTERISSUER
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
#prod issuer
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
#Modify kube-test-container-ingress.yaml for letsencrypt-prod
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod   #modify from letsencrypt-staging to letsencrypt-prod
spec:
  tls:
  - hosts:
    - test.${yourdomain}
    secretName: letsencrypt-prod                          #modify from letsencrypt-staging to letsencrypt-prod
  rules:
  - host: test.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80" | tee -a kube-test-container-ingress-prod.yaml
kubectl apply -f kube-test-container-ingress-prod.yaml
echo "
*******************************************************************************************************************
kubectl describe ingress kube-test-container-ingress to verify certificate \"letsencrypt-prod\" creation status
kubectl describe certificate letsencrypt-prod to verify certificate status
if everything looks good, you should now have a valid SSL cert to https://test.${yourdomain}
*******************************************************************************************************************
"
#END

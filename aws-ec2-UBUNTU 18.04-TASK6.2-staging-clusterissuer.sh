#!/bin/bash

#KUBERNETES STAGING CLUSTERISSUER
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
#Modify kube-test-container-ingress.yaml for letsencrypt-staging
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
  annotations:                                             #new line added
    kubernetes.io/ingress.class: nginx                     #new line added
    certmanager.k8s.io/cluster-issuer: letsencrypt-staging #new line added
spec:
  tls:
  - hosts:
    - test.${yourdomain}
    secretName: letsencrypt-staging                        #new line added
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
kubectl describe ingress     #Successfully updated Certificate "letsencrypt-staging"
kubectl describe certificate #Certificate issued successfully
#print messages of DNS record changes
echo "
*******************************************************************************************************************
kubectl describe ingress kube-test-container-ingress to verify certificate \"letsencrypt-staging\" creation status
kubectl describe certificate letsencrypt-staging to verify certificate status
*******************************************************************************************************************
"
#END

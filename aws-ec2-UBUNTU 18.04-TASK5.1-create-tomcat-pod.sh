#!/bin/bash

#KUBERNETES DEPLOYMENT - TOMCAT POD
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter domain name:'
        read yourdomain
done
#Step 2: Deploy a simple Tomcat pod with service tomcat-server exposed to ClusterIP
kubectl run tomcat --generator=run-pod/v1 --image=tomcat:alpine --port=8080 --replicas=1 && \
kubectl expose pod tomcat --type=ClusterIP --name=tomcat-server --port 80 --target-port 8080 && \
#Step 3: Set Ingress rules which route the http traffics of defined host to the backend service
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: tomcat-ingress
spec:
  tls:
  - hosts:
    - tom.${yourdomain}
    secretName: tom-${yourdomain}-secret
  rules:
  - host: tom.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: tomcat-server
          servicePort: 8080" | tee -a tomcat-ingress.yaml && \
kubectl apply -f tomcat-ingress.yaml

#print messages of DNS record changes
echo "
*******************************************************************************************************************
Change DNS record of tom.${yourdomain} to the edge node public IP
*******************************************************************************************************************
"
#END

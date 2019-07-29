#!/bin/bash

#KUBERNETES DEPLOY DASHBOARD UI AND A TOMCAT POD TO DEMONSTRATE NGINX INGRESS CONTROLLER, EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
#Step 2: Deploy a Dashboard ui image from helm
echo -e "image:
  repository: k8s.gcr.io/kubernetes-dashboard-amd64
  tag: v1.10.1
ingress:
  enabled: true
  hosts: 
    - dashboard.${yourdomain}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: \"true\"
    nginx.ingress.kubernetes.io/backend-protocol: \"HTTPS\"
  tls:
    - secretName: dashboard-${yourdomain}-tls-secret
      hosts:
      - dashboard.${yourdomain}
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
rbac:
  clusterAdminRole: true" | tee -a /tmp/kubernetes-dashboard.yaml && \
sudo helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f /tmp/kubernetes-dashboard.yaml

#Step 3: Deploy a simple Tomcat pod with service tomcat-server exposed to ClusterIP
kubectl run tomcat --generator=run-pod/v1 --image=tomcat:alpine --port=8080 --replicas=1 && \
kubectl expose pod tomcat --type=ClusterIP --name=tomcat-server && \
#Step 4: Set Ingress rules which route the http traffics of defined host to the backend service
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
          servicePort: 8080" | tee -a /tmp/tomcat-ingress.yaml && \
kubectl apply -f /tmp/tomcat-ingress.yaml
#print messages of DNS record changes and Dashboard ui token
gettoken='kubectl describe -n kube-system secret/$(kubectl -n kube-system get secret | grep kubernetes-dashboard-token|cut -d" " -f1)'
echo "
*******************************************************************************************************************
Change DNS record of tom.${yourdomain} to the edge node public IP, as tomcat-ingress is being configured, when you 
navigate https://tom.${yourdomain} tomcat-ingress will redirect https request to Pod: tomcat via Service: tomcat-server

Kubernetes-dashboard is also exposed via Ingress - https://dashboard.${yourdomain}, get token from below command
${gettoken}
*******************************************************************************************************************
"
#END

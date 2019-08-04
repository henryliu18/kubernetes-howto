#!/bin/bash

#KUBERNETES DEPLOYMENT - DASHBOARD
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter domain name:'
        read yourdomain
done
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
  clusterAdminRole: true" | tee -a kubernetes-dashboard.yaml && \
sudo helm install stable/kubernetes-dashboard \
-n kubernetes-dashboard \
--namespace kube-system  \
-f kubernetes-dashboard.yaml

#print messages of DNS record changes and Dashboard ui token
gettoken='kubectl describe -n kube-system secret/$(kubectl -n kube-system get secret | grep kubernetes-dashboard-token|cut -d" " -f1)'
echo "
*******************************************************************************************************************
Change DNS record of dashboard.${yourdomain} to the edge node public IP
Kubernetes-dashboard is exposed via Ingress - https://dashboard.${yourdomain}, get token from below command
${gettoken}
*******************************************************************************************************************
"
#END

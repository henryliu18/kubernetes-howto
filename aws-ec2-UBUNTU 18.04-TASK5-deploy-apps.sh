#!/bin/bash

#KUBERNETES DEPLOY DASHBOARD UI AND A TOMCAT POD TO DEMONSTRATE NGINX INGRESS CONTROLLER
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

#Step 5: Deploy a container for testing Kubernetes, expose to port 80
#Full description and source code: https://github.com/sverrirab/kube-test-container
echo -e "apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: kube-test-container
  name: kube-test-container
spec:
  replicas: 2
  selector:
    matchLabels:
      app: kube-test-container
  template:
    metadata:
      labels:
        app: kube-test-container
    spec:
      containers:
      - name: kube-test-container
        image: sverrirab/kube-test-container:v1.2
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 2
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 10Mi
        ports:
        - containerPort: 8000
        livenessProbe:
          httpGet:
            path: /
            port: 8000
          initialDelaySeconds: 1
          periodSeconds: 1
---
apiVersion: v1
kind: Service
metadata:
  name: kube-test-container
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8000
  selector:
    app: kube-test-container
  type: ClusterIP" | tee -a /tmp/kube-test-container-deployment.yaml && \
kubectl apply -f /tmp/kube-test-container-deployment.yaml

#Step 6: Create Ingress for kube-test-container
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
spec:
  tls:
  - hosts:
    - test.birdgg.com
    secretName: test-birdgg-secret
  rules:
  - host: test.birdgg.com
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80" | tee -a /tmp/kube-test-container-ingress.yaml && \
kubectl apply -f /tmp/kube-test-container-ingress.yaml

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

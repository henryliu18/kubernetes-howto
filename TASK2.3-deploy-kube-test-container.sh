#!/bin/bash

#KUBERNETES DEPLOYMENT - KUBE-TEST-CONTAINER
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter domain name:'
        read yourdomain
done

#Step 2: Deploy a container for testing Kubernetes, expose to port 80
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
  type: ClusterIP" | tee -a kube-test-container-deployment.yaml && \
kubectl apply -f kube-test-container-deployment.yaml

#Step 6: Create Ingress for kube-test-container
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kube-test-container-ingress
spec:
  tls:
  - hosts:
    - test.${yourdomain}
    secretName: test-${yourdomain}-secret
  rules:
  - host: test.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: kube-test-container
          servicePort: 80" | tee -a kube-test-container-ingress.yaml && \
kubectl apply -f kube-test-container-ingress.yaml

#print messages of DNS record changes and Dashboard ui token
echo "
*******************************************************************************************************************
Change DNS record of test.${yourdomain} to the edge node public IP
*******************************************************************************************************************
"
#END

#!/bin/bash

#KUBERNETES DEPLOYMENT - NODEJS SHOPPING SITE
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter domain name:'
        read yourdomain
done
#Step 2: Deploy a container for a shopping site, expose to port 80
echo -e "apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nodejs-shopping-cart
  name: nodejs-shopping-cart
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-shopping-cart
  template:
    metadata:
      labels:
        app: nodejs-shopping-cart
    spec:
      containers:
      - name: nodejs-shopping-cart
        image: henryhhl18/nodejs-shopping-cart
        imagePullPolicy: IfNotPresent
        resources:
          limits:
            cpu: 2
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 10Mi
        ports:
        - containerPort: 3000
        livenessProbe:
          httpGet:
            path: /
            port: 3000
          initialDelaySeconds: 1
          periodSeconds: 1
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-shopping-cart-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 3000
  selector:
    app: nodejs-shopping-cart
  type: ClusterIP" | tee -a nodejs-shopping-cart-deployment.yaml && \
kubectl apply -f nodejs-shopping-cart-deployment.yaml

#Step 6: Create Ingress for nodejs-shopping-cart
echo -e "apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nodejs-shopping-cart-ingress
spec:
  tls:
  - hosts:
    - shop.${yourdomain}
    secretName: shop-${yourdomain}-secret
  rules:
  - host: shop.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: nodejs-shopping-cart-service
          servicePort: 80" | tee -a nodejs-shopping-cart-ingress.yaml && \
kubectl apply -f nodejs-shopping-cart-ingress.yaml

#print messages of DNS record changes and Dashboard ui token
echo "
*******************************************************************************************************************
Change DNS record of shop.${yourdomain} to the edge node public IP
*******************************************************************************************************************
"
#END

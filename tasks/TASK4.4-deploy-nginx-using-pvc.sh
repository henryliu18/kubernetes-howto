#!/bin/bash

#Create Nginx container consuming pvc as html home /usr/share/nginx/html

#BEGIN
#Step 1: Set a valid domain name to demonstrate how Nginx-Ingress controller handles HTTPS requests, e.g. xyz.com
yourdomain=''
until [ "${yourdomain}" != '' ]; do
        echo 'enter domain name:'
        read yourdomain
done

echo -e "apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: nginx
  name: nginx-using-pvc
spec:
  replicas: 1
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      volumes:
      - name: www
        persistentVolumeClaim:
          claimName: pvc-nfs-pv1
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-using-pvc-service
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    run: nginx
  type: ClusterIP
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-using-pvc-ingress
spec:
  tls:
  - hosts:
    - pvtest.${yourdomain}
    secretName: pvtest-${yourdomain}-secret
  rules:
  - host: pvtest.${yourdomain}
    http:
      paths:
      - path: /
        backend:
          serviceName: nginx-using-pvc-service
          servicePort: 80
" | tee -a nginx-using-pvc.yaml
kubectl apply -f nginx-using-pvc.yaml
kubectl get Deployment nginx-using-pvc
kubectl get svc nginx-using-pvc-service
kubectl get ing nginx-using-pvc-ingress
#END

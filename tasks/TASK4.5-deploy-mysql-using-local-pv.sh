#!/bin/bash

#Deployment yaml example of mysql database using local persistent volume on worker node k8snode1 /home/pv1 and expose port 3306 via ClusterIP

#BEGIN
echo -e "kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-home-pv1
spec:
  capacity:
    storage: 5Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /home/pv1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8snode1
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc1
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mysql-dep
  labels:
    app: mysql
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      hostname: myssqlhostname
      containers:
      - name: mysql
        image: mysql
        ports:
        - containerPort: 3306
        volumeMounts:
        - mountPath: \"/var/lib/mysql\"
          name: storage
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: \"my-secret-pw\"
      volumes:
        - name: storage
          persistentVolumeClaim:
            claimName: pvc1
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: mysql
  name: mysql-service
spec:
  ports:
  - port: 3306
    protocol: TCP
    targetPort: 3306
  selector:
    app: mysql
status:
  loadBalancer: {}" | tee -a mysql-deployment.yaml
kubectl apply -f mysql-deployment.yaml

#check deployment and pv/pvc status
kubectl get deployment,pod,svc -l app=mysql
kubectl get pv,pvc

#clean up
kubectl delete -f mysql-deployment.yaml
rm -f mysql-deployment.yaml
#END

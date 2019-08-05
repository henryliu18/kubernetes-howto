#!/bin/bash

#Create PersistentVolume

#BEGIN
echo -e "apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs-pv1
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  nfs:
    server: k8s-master    #CHANGE THIS TO NFS SERVER
    path: \"/nfsshare\"
" | tee -a pv-nfs.yaml
kubectl apply -f pv-nfs.yaml
kubectl get PersistentVolume pv-nfs-pv1
#END

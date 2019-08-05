#!/bin/bash

#Create PersistentVolumeClaim

#BEGIN
echo -e "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-nfs-pv1
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 500Mi
" | tee -a pvc-nfs.yaml
kubectl apply -f pvc-nfs.yaml
kubectl get PersistentVolumeClaim pvc-nfs-pv1
#END

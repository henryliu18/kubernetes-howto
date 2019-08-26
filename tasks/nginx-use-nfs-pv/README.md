# Nginx web server uses nfs persistent volume

# TCP/UDP 111 and 2049 must be allowed

# NFS SERVER BUILD
```
NFS_SERVER='k8s-master'
NFS_SHARE='/nfsshare'
sudo apt install nfs-kernel-server
sudo mkdir ${NFS_SHARE}
sudo chmod 777 ${NFS_SHARE}
echo -e "${NFS_SHARE} *(rw,sync,no_subtree_check,insecure)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo exportfs -rav
sudo exportfs -v
```
# NFS CLIENT BUILD
```
sudo apt-get install nfs-common
sudo mount -t nfs ${NFS_SERVER}:${NFS_SHARE} /mnt
```
# Create pv pv-nfs-pv1 and pvc pvc-nfs-pv1
```
cat <<EOF | kubectl create -f -
apiVersion: v1
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
    path: /nfsshare
---
apiVersion: v1
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
EOF
```
# Deploy Nginx using pv
```
cat <<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
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
EOF
```

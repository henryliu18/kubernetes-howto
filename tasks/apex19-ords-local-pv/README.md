# Deploy Oracle Apex 19.1 and ORDS webapp on Tomcat in 2 containers, database files are stored on a local directory that is defined as a persistent volume in Kubernetes

Apply sequences

- create a local directory /db on a worker node for pv local-apex19-db
```
sudo mkdir /db
sudo chmod 777 /db
```
- create storage class, persistent volume and persistent volume claim
```
cat<<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-apex19-db
spec:
  capacity:
    storage: 20Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local
  local:
    path: /db             #CHANGE THIS IF NECESSARY
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - w1            #CHANGE THIS IF NECESSARY
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: pvc-apex19-db
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local
  resources:
    requests:
      storage: 20Gi
EOF
```
- create an one-time-job to copy datafiles from container fs to pv
```
echo -e 'apiVersion: batch/v1
kind: Job
metadata:
  name: copydb
spec:
  template:
    spec:
      containers:
      - name: apex19
        image: henryhhl18/apex19-container
        env:
        - name: COPYDBFROM
          value: "/u02"
        - name: COPYDBTO
          value: "/pvc_mount_point"
        command: ["/bin/bash","-c","cd $(COPYDBFROM);tar cf - * | ( cd $(COPYDBTO); tar xfp -)"]
        volumeMounts:
        - mountPath: /pvc_mount_point
          name: storage-u02
      volumes:
        - name: storage-u02
          persistentVolumeClaim:
            claimName: pvc-apex19-db
      restartPolicy: Never
  backoffLimit: 1' | tee copydb-job.yaml
```
```kubectl apply -f copydb-job.yaml```
- Deployment/Service of Oracle db/apex 19.1
```
cat<<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: apex19
  name: apex19
spec:
  replicas: 1
  selector:
    matchLabels:
      run: apex19
  template:
    metadata:
      labels:
        run: apex19
    spec:
      hostname: dbserv1
      containers:
      - image: henryhhl18/apex19-container
        name: apex19
        ports:
        - containerPort: 1521
        volumeMounts:
        - mountPath: /u02
          name: storage-u02
      volumes:
        - name: storage-u02
          persistentVolumeClaim:
            claimName: pvc-apex19-db
---
apiVersion: v1
kind: Service
metadata:
  name: dbserv1
spec:
  ports:
  - port: 1521
    protocol: TCP
    targetPort: 1521
  selector:
    run: apex19
  type: ClusterIP
EOF
```
- Deployment/Service of Oracle ords as front-end webapp on Tomcat
```
cat<<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: ords
  name: ords
spec:
  replicas: 2
  selector:
    matchLabels:
      run: ords
  template:
    metadata:
      labels:
        run: ords
    spec:
      hostname: webserv1
      containers:
      - image: henryhhl18/ords-container
        name: ords
        ports:
        - containerPort: 8080
        command: ['/bin/bash', '-c', 'sleep 60s; /bin/bash /tmp/startup-ords']
---
apiVersion: v1
kind: Service
metadata:
  name: ords-service-fe
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    run: ords
  type: NodePort
EOF
```
- Deployment/Service of standalone Apex 19.1 with ephemeral container fs
```
cat<<EOF | kubectl apply -f -
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    run: apex19
  name: apex19
spec:
  replicas: 1
  selector:
    matchLabels:
      run: apex19
  template:
    metadata:
      labels:
        run: apex19
    spec:
      hostname: dbserv1
      containers:
      - image: henryhhl18/apex19-container
        name: apex19
        env:
        - name: LOCAL
          value: "Y"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: apex19-service-8080
spec:
  ports:
  - port: 8080
    protocol: TCP
    targetPort: 8080
  selector:
    run: apex19
  type: NodePort
EOF
```

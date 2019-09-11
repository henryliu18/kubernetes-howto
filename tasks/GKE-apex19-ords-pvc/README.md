# Deploy Oracle Apex 19.1 and ORDS webapp on Tomcat in 2 containers, database files are stored on GCP Disk that is defined as a persistent volume in Kubernetes

## Create pvc pvc-apex19-db
```
cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-apex19-db
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 20Gi
EOF
```
## create an one-time-job to copy datafiles from container fs to pvc-apex19-db
```
echo -e 'apiVersion: batch/v1
kind: Job
metadata:
  name: copydb
spec:
  template:
    spec:
      securityContext:
        fsGroup: 54321
        runAsUser: 54321
        runAsGroup: 54321
      containers:
      - name: apex19
        image: docker.io/henryhhl18/apex19-container
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
## Deployment/Service of Oracle db/apex 19.1
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
      - image: docker.io/henryhhl18/apex19-container
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
## Deployment/Service of Oracle ords as front-end webapp on Tomcat
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
      - image: docker.io/henryhhl18/ords-container
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
  type: LoadBalancer
EOF
```
## Clean up
```
kubectl delete svc ords-service-fe
kubectl delete Deployment ords
kubectl delete svc dbserv1
kubectl delete Deployment apex19
kubectl delete pvc pvc-apex19-db
```

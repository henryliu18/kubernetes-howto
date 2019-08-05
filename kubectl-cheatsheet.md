kubectl run centos --generator=run-pod/v1 --image=centos --replicas=1 --command -- sleep infinity
kubectl run busybox --generator=run-pod/v1 --image=busybox --replicas=1 --command -- sleep infinity
kubectl run ubuntu --generator=run-pod/v1 --image=ubuntu --replicas=1 --command -- sleep infinity

kubectl run tomcat --generator=run-pod/v1 --image=tomcat:alpine --port=8080 --replicas=1
kubectl expose pod tomcat --type=ClusterIP --name=tomcat-server

#expose Nginx web server (ngx) via ClusterIP, access ngx inside the cluster
kubectl run ngx  --generator=run-pod/v1 --image=docker.io/nginx:alpine --port=80
kubectl expose pod ngx --port=80 --target-port=80 --name=ngx --type=ClusterIP
kubectl run curl --generator=run-pod/v1 --image=appropriate/curl ngx

#expose NodePort
kubectl run nodejs-shopping-cart --generator=run-pod/v1 --image=henryhhl18/nodejs-shopping-cart --port=3000
kubectl expose pod nodejs-shopping-cart --type=NodePort --name=nodejs-shopping-cart

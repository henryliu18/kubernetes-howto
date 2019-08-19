#get  
kubectl get cs  
kubectl get node  
kubectl get pod  
kubectl get svc  
kubectl get ingress  

kubectl get pod -n kube-system  

kubectl get pod,svc,ing --all-namespaces  

#dry run  
kubectl create deploy nginx --image nginx --dry-run -o yaml  

#run a pod  
kubectl run centos --generator=run-pod/v1 --image=centos --replicas=1 --command -- sleep infinity  
kubectl run busybox --generator=run-pod/v1 --image=busybox --replicas=1 --command -- sleep infinity  
kubectl run ubuntu --generator=run-pod/v1 --image=ubuntu --replicas=1 --command -- sleep infinity  
kubectl run henrytoolbox --generator=run-pod/v1 --image=henryhhl18/toolbox --replicas=1 --command -- sleep 30000d

#expose ClusterIP  
kubectl run tomcat --generator=run-pod/v1 --image=tomcat:alpine --port=8080 --replicas=1  
kubectl expose pod tomcat --type=ClusterIP --name=tomcat-server  

#expose Nginx web server (ngx) via ClusterIP, access ngx inside the cluster  
kubectl run ngx  --generator=run-pod/v1 --image=docker.io/nginx:alpine --port=80  
kubectl expose pod ngx --port=80 --target-port=80 --name=ngx --type=ClusterIP  
kubectl run curl --generator=run-pod/v1 --image=appropriate/curl ngx  

#expose NodePort  
kubectl run nodejs-shopping-cart --generator=run-pod/v1 --image=henryhhl18/nodejs-shopping-cart --port=3000  
kubectl expose pod nodejs-shopping-cart --type=NodePort --name=nodejs-shopping-cart  

#get token of serviceaccount "dashboard" for Dashboard ui access  
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode  

#start Dashboard  
kubectl proxy  

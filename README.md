-AWS EC2 baremetal  
Ubuntu 18.04  
Kubernetes version: v1.15.0

Follow aws-ec2* for the build

Nginx Ingress Controller (free)  
default vpc  
public ip for edge node  
security group for Kubernetes nodes - SGk8s  
  Inbound:  
    -tcp 22 anywhere (ssh)  
    -tcp 30000-32767 anywhere  
    -tcp 2379-2380 anywhere  
    -tcp 443 anywhere  
    -tcp 6443 anywhere  
    -tcp 10250 anywhere  
    -tcp 179 anywhere  
    -udp 8285 anywhere  
    -udp 8472 anywhere  

AWS ELB  
default vpc  
public ip  
security group for Kubernetes nodes - SGk8s  
  Inbound:  
    -tcp 22 anywhere (ssh)  
    -tcp 30000-32767 anywhere  
    -tcp 2379-2380 anywhere  
    -tcp 443 anywhere  
    -tcp 6443 anywhere  
    -tcp 10250 anywhere  
    -tcp 179 anywhere  
    -udp 8285 anywhere  
    -udp 8472 anywhere  
    -tcp Target-Port LoadBalancer-security-group  e.g. tcp 8080 LoadBalancer-security-group  
security group for AWS ELB - SGELB  
  Inbound:  
    -tcp 80 anywhere  

-VIRTUALBOX  
CentOS Linux release 7.6.1810 (Core)  
Kubernetes version: v1.15.0

Deployment  
yum install git -y  && git clone https://github.com/henryliu18/kubernetes-poc.git  && cd kubernetes-poc  
Review hosts for environment  
Review (master host) THIS_NODE_HOST and THIS_NODE_IP => master.sh  
Review (node host)THIS_NODE_HOST => node.sh

Deploy master -> master.sh  
 Node join command, dashboard-admin token is logged in /tmp/k8smaster.log  
Deploy node -> node.sh -> run node join command from above step

master commands:  
kubectl get cs  
kubectl get nodes  
kubectl get pods  
kubectl get services  
kubectl get pods -n kube-system  
kubectl get services -n kube-system  

#Get token of serviceaccount "dashboard" for Dashboard ui access  
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

Dashboard start  
kubectl proxy

Dashboard UI URL  
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

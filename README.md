-AWS EC2  
Ubuntu 18.04  
Kubernetes version: v1.15.0

Follow aws-ec2* for the build (manual)  
Follow aws-ec2*-userdata for the build (auto)  

Load Balancer solution: Nginx Ingress Controller  
Default vpc  
Public ip  
Security Group for master node  
![Security Group for master node](https://github.com/henryliu18/kubernetes-poc/raw/master/security-group-master.PNG)

Security Group for worker node  
![Security Group for worker node](https://github.com/henryliu18/kubernetes-poc/raw/master/security-group-worker.PNG)

Security Group for general admin  
![Security Group for server admin](https://github.com/henryliu18/kubernetes-poc/raw/master/security-group-serveradmin.PNG)

Load Balancer solution: AWS ELB  
default vpc  
Public ip  
Security Group for master node  
  -Inbound:  
    TCP 6443  
    TCP 443  
    TCP 2379-2380  
    UDP 8285  
    UDP 8472  
    TCP Security-Group-of-ELB  

Security Group for worker node  
  -Inbound  
    TCP 30000-32767  
    TCP 10250  
    TCP 10255  
    TCP 179  
    TCP 2379-2380  

Security Group for ELB  
  Inbound:  
    -tcp 80 anywhere  

Security Group for general admin  
  -Inbound  
    TCP 22  
    All ICMP IPV4  

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

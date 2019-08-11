![Kubernetes architecture](https://github.com/henryliu18/kubernetes-poc/raw/master/images/Kubernetes-architecture.PNG)


-AWS EC2  
Ubuntu 18.04  
Kubernetes version: v1.15.0

Follow aws-ec2* for the build (manual)  
Follow aws-ec2*-userdata for the build (auto)  

Load Balancer solution: Nginx Ingress Controller  
Default vpc  
Public ip  
Security Group for master node  
![Security Group for master node](https://github.com/henryliu18/kubernetes-poc/raw/master/images/security-group-master.PNG)

Security Group for worker node  
![Security Group for worker node](https://github.com/henryliu18/kubernetes-poc/raw/master/images/security-group-worker.PNG)

Security Group for general admin  
![Security Group for server admin](https://github.com/henryliu18/kubernetes-poc/raw/master/images/security-group-serveradmin.PNG)

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
yum install git -y  && git clone https://github.com/henryliu18/kubernetes-poc.git  && cd kubernetes-poc/setup  

Master node -> virtualbox-centos7.6-manual-master.sh  
Worker node -> virtualbox-centos7.6-manual-worker.sh  

Dashboard UI URL  
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/  

[Troubleshooting dns not resolving]  
- Ports blocking - check Firewall/Security group  
- Multiple NICs causing CNI confused - solution -> specify a servicing NIC in yaml file  
E.g.  
containers:  
      - name: kube-flannel  
        image: quay.io/coreos/flannel:v0.11.0-amd64  
        command:  
        - /opt/bin/flanneld  
        args:  
        - --ip-masq  
        - --kube-subnet-mgr  
        - --iface=eth1  #replacing eth1 with servicing NIC name  

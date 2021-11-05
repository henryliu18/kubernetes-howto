# Kubernetes howto

## Istio service mesh
* [K8s cluster setup](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/K8s-cluster-setup)
  - [helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/helm) => The package manager for Kubernetes
  - [metallb](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/metallb) => a bare metal load balancer solution
  - [cert-manager](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/cert-manager-helm) => certificate management controller
  - [istio](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/istio) => service mesh (GKE tested)
  - [Haproxy build for metallb](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/Haproxy-build-for-metallb) => K8s worker and Haproxy configuration for metallb connectivity
  - [Oracle Apex 19.1 on database 18c and ORDS](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/apex19-ords-local-pv)

## Bare metal Kubernetes
- [toolbox](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/toolbox) => small container deployment
- [nginx ingress control helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/ingress-control-helm) => install nginx-ingress from helm
- [tomcat nginx ingress](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/tomcat-ingress) => deploy tomcat with nginx-ingress
- [kubernetes dashboard helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/kubernetes-dashboard-helm) => install dashboard webui from helm and configured it with nginx-ingress
- [cert-manager](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/cert-manager-helm) => certificate management controller
- [statefulset](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/statefulset) => showcase pod/pv dependent and how sts manages replicas dependently as a service
- [mysql use local pv](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/mysql-use-local-pv) => Mysql on a persistent storage
- [nginx use nfs pv](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/nginx-use-nfs-pv) => another persistet volume example with NFS
- [initContainers](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/initContainers) => initContainer runs tasks before the pod is deployed
- [multi container pod](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/multi-container-pod) => containers sharing kernel namespace/IPC/volumes
- [users and permissions](https://github.com/henryliu18/kubernetes-howto/blob/master/tasks/rbac/user-role-rolebinding.md) => user cert/key and rbac example (Updated Oct 2021)
- [ArgoCD](https://github.com/henryliu18/kubernetes-howto/tree/master/tasks/ArgoCD) => Continuous Deployment in Kubernetes (Updated Oct 2021)
- [Kubeseal](https://github.com/henryliu18/kubernetes-howto/tree/master/tasks/kubeseal) => Encrypt secrets to safely push encrypted string to code repo for GitOps.

## Managed Kubernetes
* [GKE Oracle Apex 19.1 on database 18c and ORDS](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/GKE-apex19-ords-pvc) => Oracle Apex 19.1 and ORDS webapp on Tomcat in 2 containers, database files are stored on GCP Disk

## Bare metal K8s/Kubespray/Ingress Nginx/Cert-manager/Azure VM/Azure Load Balancer (Updated Oct 2021)
- [Security Group](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/azure/security-group.md) => Configure Azure Security Group for Kubernetes
- [Static public IP](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/azure/public-static-ip-address.md) => Create 2 static public IP address SKU for all K8s nodes
- [Virtual Machine](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/azure/create-vm.md) => Create 2 VMs for control plane and worker node
- [Kubespray](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/K8s-cluster-setup/K8s-Kubespray.md) => Configure Kubespray, create K8s cluster
- [Post-installation](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/config/post-installation.md) => copy config file to user's home directory
- [Helm](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/helm/README.md) => Install Helm
- [Ingress controller](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/ingress-controller/ingress-nginx.md) => Install ingress-nginx
- [Load Balancer](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/azure/load-balancer.md) => Create/configure Azure Load Balancer for ingress-nginx port 80 and 443
- [Deployment](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/tomcat-ingress) => Deploy tomcat/nginx web server for testing
- [Testing](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/azure/testing.md) => Testing Load Balancer, Ingress controller
- [Selfsign certificate](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/Selfsigned-cert) => [Manual] Securing webapps
- [cert-manager/let's encrypt](https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/cert-manager-helm/README.md) => [Automation] Install cert-manager, request for SSL certificate from let's encrypt
- [SSLForFree](https://github.com/henryliu18/kubernetes-howto/blob/master/tasks/install-ssl/readmd.MD) => [Manual] Create a free SSL certificate and install it manually

## Bare metal K3s/Ingress Nginx/Cert-manager (Updated Oct 2021)
- [Get started K3s](https://github.com/henryliu18/kubernetes-howto/blob/master/tasks/k3s/readme.md) - The certified Kubernetes distribution built for IoT & Edge computing
- [microk8s on ARM64](https://github.com/henryliu18/kubernetes-howto/tree/master/tasks/microk8s) - for micro clouds and edge computing

# Bare metal K8s tasks

## Istio service mesh practices
* [K8s cluster setup](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/K8s-cluster-setup)
  - [helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/helm) => The package manager for Kubernetes
  - [metallb](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/metallb) => a bare metal load balancer solution
  - [istio](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/istio) => service mesh (GKE tested)
  - [Haproxy build for metallb](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/Haproxy-build-for-metallb) => K8s worker and Haproxy configuration for metallb connectivity
  - [Oracle Apex 19.1 on database 18c and ORDS](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/apex19-ords-local-pv)

## Standard K8s practices
- [toolbox](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/toolbox) => small container deployment
- [nginx ingress control helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/ingress-control-helm) => install nginx-ingress from helm
- [tomcat nginx ingress](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/tomcat-ingress) => deploy tomcat with nginx-ingress
- [kubernetes dashboard helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/kubernetes-dashboard-helm) => install dashboard webui from helm and configured it with nginx-ingress
- [cert manager helm](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/cert-manager-helm) => install cert-manager from helm and sign a free cert of Let's encrypt to a Tomcat deployment
- [statefulset](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/statefulset) => showcase pod/pv dependent and how sts manages replicas dependently as a service
- [mysql use local pv](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/mysql-use-local-pv) => Mysql on a persistent storage
- [nginx use nfs pv](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/nginx-use-nfs-pv) => another persistet volume example with NFS
- [initContainers](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/initContainers) => initContainer runs tasks before the pod is deployed
- [multi container pod](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/multi-container-pod) => containers sharing kernel namespace/IPC/volumes

# Managed K8s tasks
* [GKE Oracle Apex 19.1 on database 18c and ORDS](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/GKE-apex19-ords-pvc) => Oracle Apex 19.1 and ORDS webapp on Tomcat in 2 containers, database files are stored on GCP Disk
* [Selfsign cert for cloud load balancer](https://github.com/henryliu18/kubernetes-poc/tree/master/tasks/Selfsigned-cert-cloudLB)

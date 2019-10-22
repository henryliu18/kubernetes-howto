# some tasks to perform

suggested sequence
* K8s-cluster-setup
  - helm => The package manager for Kubernetes
  - metallb => a bare metal load balancer solution
  - istio => service mesh (GKE tested)
  - Haproxy-build-for-metallb => K8s worker and Haproxy configuration for metallb setup
- toolbox => small container deployment
- ingress-control-helm => install nginx-ingress from helm
- tomcat-ingress => deploy tomcat with nginx-ingress
- kubernetes-dashboard-helm => install dashboard webui from helm
- cert-manager-helm => install cert-manager from helm and sign a free cert of Let's encrypt to a Tomcat deployment
- statefulset => showcase pod/pv dependent and how sts manages replicas dependently as a service
- mysql-use-local-pv => Mysql on a persistent storage
- apex19-ords-local-pv => Oracle databasae Apex 19.1 on a persistent storage with a separated Tomcat container
- nginx-use-nfs-pv => another persistet volume example with NFS
- initContainers => initContainer runs tasks before the pod is deployed
- multi-container-pod => containers sharing kernel namespace/IPC/volumes

# some tasks to perform

suggested sequence
- prerequisite => env setup
- toolbox => small container deployment
- helm => The package manager for Kubernetes
- ingress-control-helm => install nginx-ingress from helm
- kubernetes-dashboard-helm => install dashboard webui from helm
- cert-manager-helm => install cert-manager from helm and sign a free cert of Let's encrypt to a Tomcat deployment
- metallb => a bare metal load balancer solution
- statefulset => showcase pod/pv dependent and how sts manages replicas dependently as a service
- mysql-use-local-pv => Mysql on a persistent storage
- apex19-ords-local-pv => Oracle databasae Apex 19.1 on a persistent storage with a separated Tomcat container
- nginx-use-nfs-pv => another persistet volume example with NFS
- initContainers => initContainer runs tasks before the pod is deployed
- multi-container-pod => containers sharing kernel namespace/IPC/volumes
- istio => service mesh

# The Ingress is a Kubernetes resource that lets you configure an HTTP load balancer for applications running on Kubernetes, represented by one or more Services. Such a load balancer is necessary to deliver those applications to clients outside of the Kubernetes cluster.

## Create namespace
```kubectl create ns nginx-system```
## Update helm repo (optional)
```helm repo update```
## Install Nginx Ingress Controller (preferred)
```helm install nginx-ingress stable/nginx-ingress --namespace nginx-system --set controller.publishService.enabled=true```
## Install Nginx Ingress Controller (customised)
### Nominate a worker node to be labelled edge for ingress control node, this will make the node as internet facing node
```bash
until [ "${edge_nodename}" != '' ]; do
        echo 'enter edge node name:'
        read edge_nodename
done
```
### Label edge to a selected worker node
```kubectl label node ${edge_nodename} node-role.kubernetes.io/edge=```
### Create Namespace
```kubectl create ns nginx-system```
### Install Nginx Ingress Controller
```yaml
cat <<EOF | helm install nginx-ingress stable/nginx-ingress --namespace nginx-system -f -
controller:
  replicaCount: 1
  hostNetwork: true
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  affinity:
    podAntiAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - nginx-ingress
            - key: component
              operator: In
              values:
              - controller
          topologyKey: kubernetes.io/hostname
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
defaultBackend:
  nodeSelector:
    node-role.kubernetes.io/edge: ''
  tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: PreferNoSchedule
EOF
```
## Clean up
```
helm uninstall nginx-ingress --namespace nginx-system
kubectl delete ns nginx-system
```

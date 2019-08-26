# The Ingress is a Kubernetes resource that lets you configure an HTTP load balancer for applications running on Kubernetes, represented by one or more Services. Such a load balancer is necessary to deliver those applications to clients outside of the Kubernetes cluster.

# Nominate a worker node to be labelled edge for ingress control node, this will make the node as internet facing node
```
until [ "${edge_nodename}" != '' ]; do
        echo 'enter edge node name:'
        read edge_nodename
done
```
# Label edge to a selected worker node
```sudo kubectl label node ${edge_nodename} node-role.kubernetes.io/edge=```
# Update helm repo
```helm repo update```
# Create yaml for Nginx Ingress Controller
```
cat <<EOF | helm install stable/nginx-ingress -n nginx-ingress --namespace ingress-nginx -f -
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

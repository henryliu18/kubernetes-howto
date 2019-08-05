#!/bin/bash

#KUBERNETES EDGE NODE BUILD FOR AWS EC2 UBUNTU 18.04 LTS, EDGE NODE ACTS AS L7 LOAD BALANCER FOR HTTPS PROXY
#(IMPLEMENTED BY NGINX INGRESS CONTROLLER), EXECUTE BELOW ON THE MASTER NODE

#BEGIN
#Step 1: Set edge node name, node name can be listed by running kubectl get node, try not to use master as edge node
edge_nodename=''
until [ "${edge_nodename}" != '' ]; do
        echo 'enter edge node name:'
        read edge_nodename
done
#Step 2: Label selected worker node(s) edge (open to internet) which will be selected to deploy Nginx Ingress Controller in yaml below (nodeSelector)
sudo kubectl label node ${edge_nodename} node-role.kubernetes.io/edge= && \
#Step 3: Create yaml for Nginx Ingress Controller on edge node
echo -e "controller:
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
        effect: PreferNoSchedule" | tee -a ingress-nginx.yaml && \
#Step 4: Update helm repo
sudo helm repo update && \
#Step 5: Install Nginx-Ingress using helm - namespace nginx-ingress
sudo helm install stable/nginx-ingress \
-n nginx-ingress \
--namespace ingress-nginx  \
-f ingress-nginx.yaml
echo "Node: ${edge_nodename} is labeled as edge and has nginx-ingress deployed to it"
#END

# Set a valid domain name to be signed TLS certificate and handled by nginx-ingress
```
unset fqdn
until [ "${fqdn}" != '' ]; do
        echo 'enter full qualified domain name (example: dashboard.xyz.com):'
        read fqdn
done
```
# Create stable/kubernetes-dashboard helm yaml
```
echo -e "image:
  repository: k8s.gcr.io/kubernetes-dashboard-amd64
  tag: v1.10.1
ingress:
  enabled: true
  hosts: 
    - ${fqdn}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: \"true\"
    nginx.ingress.kubernetes.io/backend-protocol: \"HTTPS\"
  tls:
    - secretName: dashboard-tls-secret
      hosts:
      - ${fqdn}
nodeSelector:
    node-role.kubernetes.io/edge: ''
tolerations:
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: PreferNoSchedule
rbac:
  clusterAdminRole: true" | tee -a /tmp/kubernetes-dashboard.yaml
```
# Install stable/kubernetes-dashboard
```helm install stable/kubernetes-dashboard -n kubernetes-dashboard --namespace kube-system -f /tmp/kubernetes-dashboard.yaml```
# Change A record of ${fqdn} to the edge node public IP
# Get your token
```kubectl describe -n kube-system secret/$(kubectl -n kube-system get secret | grep kubernetes-dashboard-token|cut -d" " -f1)```

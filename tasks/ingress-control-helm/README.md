# The Ingress is a Kubernetes resource that lets you configure an HTTP load balancer for applications running on Kubernetes, represented by one or more Services. Such a load balancer is necessary to deliver those applications to clients outside of the Kubernetes cluster.

## Update helm repo (optional)
```helm repo update```
## Install Nginx Ingress Controller
```helm install stable/nginx-ingress --name nginx-ingress --set controller.publishService.enabled=true```
## Clean up
```helm del nginx-ingress --purge```

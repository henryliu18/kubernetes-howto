# Baremetal style of K8s/metallb/istio/cert-manager deployment with Haproxy and cloud vendor managed load balancer for external access via an external dns server

# Requirements:
## 2 VMs for K8s master and worker node (public ip)
## 2 VMs for Haproxy (public ip)
## 1 cloud vendor managed Load Balancer (public ip)
## 1 valid DNS record that points to Load Balancer
## 1 email address for creating Let's encrypt certificate

# Deployment steps
## K8s stack (K8s/helm/metallb/istio/cert-manager)
## DNS validation
## Haproxy installation and configuration
## Container deployment (Tomcat)
## Create Let's encrypt certificate for Tomcat web server

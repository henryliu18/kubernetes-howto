#!/bin/bash

#KUBERNETES INSTALLING AND CONFIGURING CERT-MANAGER
#EXECUTE BELOW ON THE MASTER NODE

#BEGIN
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.8/deploy/manifests/00-crds.yaml
kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"
sudo helm repo add jetstack https://charts.jetstack.io
sudo helm repo update
sudo helm install --name cert-manager --namespace kube-system jetstack/cert-manager --version v0.8.0
#END

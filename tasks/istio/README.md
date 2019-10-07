# Istio

## Download the release - https://istio.io/docs/setup/#downloading-the-release
```curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.1 sh -```
## cp istioctl to /usr/local/bin
```sudo cp istio-1.3.1/bin/istioctl /usr/local/bin```
## Istio precheck
```istioctl verify-install```
## Install Istio-init from helm with tiller, 3 jobs to be run to init
```
cd istio-*
kubectl create namespace istio-system
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
## Verify Istio-init installation
```watch kubectl get all -n istio-system```

## Create a secret for Kiali
```
KIALI_USERNAME=$(echo -n admin | base64)
KIALI_PASSPHRASE=$(echo -n pass | base64)
```
## specify Istio ns
```NAMESPACE=istio-system```
## apply yaml to create a secret
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $NAMESPACE
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
```

## Install Istio from helm with tiller
```helm install install/kubernetes/helm/istio --name istio --namespace istio-system```

## Enable some oberserability
```helm install install/kubernetes/helm/istio --name istio --namespace istio-system --set grafana.enabled=True --set kiali.enabled=True```

## Verify Istio
```watch kubectl get all -n istio-system```

# Bookinfo

## Label the namespace that will host the application with istio-injection=enabled
```kubectl label namespace default istio-injection=enabled```
## Deploy app
```kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml```
## Confirm app is running
```kubectl exec -it $(kubectl get pod -l app=ratings -o jsonpath='{.items[0].metadata.name}') -c ratings -- curl productpage:9080/productpage | grep -o "<title>.*</title>"```
## Create Istio gateway and virtualservice
```kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml```

# Kiali - https://istio.io/docs/tasks/telemetry/kiali/

## Get Kiali pod name
```kubectl get pod -n istio-system|grep kiali```
## Get Kiali service name
```kubectl get svc -n istio-system | grep kiali```
## Change from ClusterIP to LoadBalancer or NodePort to access Kiali outside the cluster
```kubectl edit svc kiali -n istio-system```
## Access Kiali Console
http://LoadBalancer-IP:20001

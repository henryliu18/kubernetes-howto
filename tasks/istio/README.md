# Istio release setup
```
curl -L https://git.io/getLatestIstio | ISTIO_VERSION=1.3.3 sh -
cd istio-1.3.3
export PATH=$PWD/bin:$PATH
istioctl verify-install
```

# Install all the Istio Custom Resource Definitions (CRDs)
```for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done```

# Istio-init
```
kubectl create namespace istio-system
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl apply -f -
```

# Enables Istio’s SDS (secret discovery service). This profile comes with additional authentication features enabled by default.
```
helm template install/kubernetes/helm/istio --name istio --namespace istio-system \
    --values install/kubernetes/helm/istio/values-istio-sds-auth.yaml | kubectl apply -f -
```

## Create a secret for Kiali
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: $(echo -n istio-system)
  labels:
    app: kiali
type: Opaque
data:
  username: $(echo -n admin | base64)
  passphrase: $(echo -n pass | base64)
EOF
```
# Enable observability - Grafana and Kiali
```helm template install/kubernetes/helm/istio --name istio --namespace istio-system --set grafana.enabled=True --set kiali.enabled=True | kubectl apply -f -```

## Cleanup
```
helm template install/kubernetes/helm/istio --name istio --namespace istio-system --set grafana.enabled=True --set kiali.enabled=True | kubectl delete -f -
helm template install/kubernetes/helm/istio-init --name istio-init --namespace istio-system | kubectl delete -f -
kubectl delete namespace istio-system
sudo rm -f /usr/local/bin/istioctl
```

# https://metallb.universe.tf/

# Installation - https://metallb.universe.tf/installation/

```kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.1/manifests/metallb.yaml```

# https://metallb.universe.tf/configuration/#layer-2-configuration

```
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 10.244.1.220-10.244.1.250              #gives MetalLB control over cluster IP range
```

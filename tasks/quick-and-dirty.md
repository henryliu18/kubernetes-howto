
```bash
kubectl create deployment nginx --image=nginx
kubectl create service nodeport nginx --tcp=80:80

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-nginx
  annotations:
    # use the shared ingress-nginx
    kubernetes.io/ingress.class: "public"
spec:
  rules:
  - host: www.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF

kubectl get pods
kubectl exec --stdin --tty nginx-6799fc88d8-pdxnm -- /bin/bash
```

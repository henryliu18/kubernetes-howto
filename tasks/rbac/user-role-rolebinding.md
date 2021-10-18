# Create certificate and private key for user

### Constants
```bash
NEW_USER=john
NAMESPACE=dev
CLUSTER_NAME=kubernetes
APISERVER=https://10.176.92.41:6443
NEW_KUBECONFIG=john.kubeconfig
CONTEXT_NAME=john-context
```

### Create namespace
```bash
kubectl create namespace ${NAMESPACE}
```

### Create private key, certificate request and certificate for user
```bash
openssl genrsa -out ${NEW_USER}.key 2048
openssl req -new -key ${NEW_USER}.key -out $NEW_USER.csr -subj "/CN=${NEW_USER}/O=${NAMESPACE}"
sudo openssl x509 -req -in ${NEW_USER}.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out ${NEW_USER}.crt -days 365
sudo chown $(whoami):$(id -Gn) ${NEW_USER}.crt
```

### Make kubeconfig for user
```bash
sudo kubectl --kubeconfig ${NEW_KUBECONFIG} config set-cluster kubernetes --server https://10.176.92.41:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
sudo kubectl --kubeconfig ${NEW_KUBECONFIG} config set-credentials ${NEW_USER} --client-certificate ${NEW_USER}.crt --client-key ${NEW_USER}.key --embed-certs=true
sudo kubectl --kubeconfig ${NEW_KUBECONFIG} config set-context ${CONTEXT_NAME} --cluster ${CLUSTER_NAME} --namespace ${NAMESPACE} --user ${NEW_USER}
```
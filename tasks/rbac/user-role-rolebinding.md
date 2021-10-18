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
```

### Make kubeconfig for user
```bash
kubectl --kubeconfig ${NEW_KUBECONFIG} config set-cluster ${CLUSTER_NAME} --server ${APISERVER} --certificate-authority=$(sudo cat /etc/kubernetes/pki/ca.crt | base64 -w0)
kubectl --kubeconfig ${NEW_KUBECONFIG} config set-credentials ${NEW_USER} --client-certificate=$(sudo cat ${NEW_USER}.crt | base64 -w0) --client-key=$(sudo cat ${NEW_USER}.key | base64 -w0)
kubectl --kubeconfig ${NEW_KUBECONFIG} config set-context ${CONTEXT_NAME} --cluster ${CLUSTER_NAME} --namespace ${NAMESPACE} --user ${NEW_USER}
```

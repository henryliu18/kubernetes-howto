# Self-sign a certificate for a webapp ingress control by nginx
* Generate private key and self sign a certificate for a domain
```bash
KEY_FILE=tls.key
CERT_FILE=tls.crt
HOST=www.example.com
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout ${KEY_FILE} -out ${CERT_FILE} -subj "/CN=${HOST}/O=${HOST}"
```
* Create a secret with the key/certificate that we just singed
```bash
CERT_NAME=tls-www-example-ingress
kubectl create secret tls ${CERT_NAME} --key ${KEY_FILE} --cert ${CERT_FILE}
# verify
kubectl describe secret ${CERT_NAME}
```
* Assign tls with the secret that we just created to ingress of the webapp
```yaml
kubectl edit ingress/www-ingress
(skip)
spec:
  rules:
  - host: www.example.com
    http:
      paths:
      - backend:
          serviceName: www-service
          servicePort: 80
  tls:
  - secretName: tls-www-example-ingress
    hosts:
    - www.example.com
(skip)
```
* Navigate to https://www.example.com

# Use www.sslforfree.com to validate domains (DNS TXT record) and sign certificates on behalf of the domain owner with Let's encrypt ACME server
* Make sure the webapp is working at port 80
* Goto https://www.sslforfree.com and enter the domain name to be SSL certified
* Choose Manual Verification (DNS) and you will be given TXT host/value, make a change to your DNS service provider
* Complete validation process and hit download certificate, you will be given Certificate/Private Key/CA Bundle in the next page, copy/paste them into 3 files for K8s secret creation later
* Create a secret with the key/certificate file in the previous step
```bash
kubectl create secret tls tls-hello-ingress --key "key.hello" --cert "cert.hello"
```
* Assign tls with the secret that we just created to ingress of the webapp
```yaml
kubectl edit ingress/hello-ingress
(skip)
spec:
  rules:
  - host: hello.example.com
    http:
      paths:
      - backend:
          serviceName: hello-service
          servicePort: 5000
  tls:
  - secretName: tls-hello-ingress
    hosts:
    - hello.example.com
(skip)
```
* Navigate to https://hello.example.com

# Cloud provider managed load balancer for serving all haproxy endpoints for Tomcat service
* Selecing all haproxy VMs for backends
* Backend port is 80 (metallb load balancer servicing port)
* Frontend Listener port is 80 for ingress traffic

## Testing managed load balancer endpoint of Tomcat service
```http://<cloud-load-balancer-public-ip>/```

## Set up DNS A record for tom.busyapi.com -> cloud-load-balancer-public-ip and test it
```http://tom.busyapi.com/```

## Enabling SSL for testing, you will need to create your own CA and Private key

* Generate the private key of the root CA

```openssl genrsa -out rootCAKey.pem 2048```

* Generate the self-signed root CA certificate

```openssl req -x509 -sha256 -new -nodes -key rootCAKey.pem -days 3650 -out rootCACert.pem```

* rootCACert.pem for CA and SSL certificate and rootCAKey.pem for private key to create certificate for cloud LB listener
```bash
ls -l
total 8
-rw-r--r-- 1 root root 1391 Oct 18 05:02 rootCACert.pem
-rw-r--r-- 1 root root 1675 Oct 18 05:01 rootCAKey.pem
```

* Create a new Listener for HTTPS requests using certificate created above

## Testing of SSL enabled tom.busyapi.com, -k allows curl to perform "insecure" SSL connections and transfers.
```curl -k https://tom.busyapi.com/```

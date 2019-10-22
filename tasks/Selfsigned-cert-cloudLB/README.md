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
```
ls -l
total 8
-rw-r--r-- 1 root root 1391 Oct 18 05:02 rootCACert.pem
-rw-r--r-- 1 root root 1675 Oct 18 05:01 rootCAKey.pem
```

* Create a new Listener for HTTPS requests using certificate created above

## Testing of SSL enabled tom.busyapi.com, -k allows curl to perform "insecure" SSL connections and transfers.
```curl -k https://tom.busyapi.com/```

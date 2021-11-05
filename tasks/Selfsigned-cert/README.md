# Self sign root CA and certificate/private key

1. Create root private key - rootCA.key
```bash
openssl genrsa \
-out rootCA.key 4096
```

2. Create root CA certificate from rootCA.key
```bash
openssl req -x509 -new -nodes \
-key rootCA.key \
-sha256 \
-days 1024 \
-out rootCA.crt

You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [AU]:AU
State or Province Name (full name) [Some-State]:VIC
Locality Name (eg, city) []:Melbourne
Organization Name (eg, company) [Internet Widgits Pty Ltd]:Trust me company
Organizational Unit Name (eg, section) []:Secret unit
Common Name (e.g. server FQDN or YOUR name) []:trust-me.com
Email Address []:admin@trust-me.com
```

3. Create a private key - tomcat.cheesemm.com.key
```bash
openssl genrsa \
-out tomcat.cheesemm.com.key 2048
```

4. Create certificate signing request (CSR) using tomcat.cheesemm.com.key
```bash
openssl req -new -sha256 \
-key tomcat.cheesemm.com.key \
-subj "/C=AU/ST=VIC/O=A Cool Org, Inc./CN=tomcat.cheesemm.com" \
-out tomcat.cheesemm.com.csr
```

5. Generate the certificate using CSR along with the CA rootCA.crt and rootCA.key
```bash
openssl x509 -req \
-in tomcat.cheesemm.com.csr \
-CA rootCA.crt \
-CAkey rootCA.key \
-CAcreateserial \
-out tomcat.cheesemm.com.crt \
-days 500 \
-sha256
```

6. Verify certificate
```bash
openssl x509 \
-in tomcat.cheesemm.com.crt \
-text \
-noout
```

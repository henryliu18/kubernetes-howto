## Get Load Balancer public IP address
![image](https://user-images.githubusercontent.com/45472005/137054032-7ca55388-29b5-40bb-ab5f-1ab0d2e092ce.png)

## Just test it without host
```bash
curl 20.53.66.120
```

### 404 Not Found is the expected result as there is no host to be resolved by Ingress controller
```bash
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```

## Test it again with nginx.example.com
```bash
curl 20.53.66.120 -HHost:nginx.example.com
```

### Nginx web server can be resolved correctly based on host
```bash
azureuser@node1:~$ curl 20.53.66.120 -HHost:nginx.example.com
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

## A record for nginx.example.com
#### Go to DNS, make an A record for nginx.example.com -> 20.53.66.120
#### When this new A record is valid then you should get the same result by executing below command
```bash
curl nginx.example.com
```

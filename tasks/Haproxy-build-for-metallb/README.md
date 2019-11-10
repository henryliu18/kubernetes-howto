# Haproxy build - 1 vCPU, 1.7 GB, Centos 7, default-allow-http, default-allow-https, k8s-worker
* * https://github.com/henryliu18/kubernetes-poc/blob/master/tasks/K8s-cluster-setup/K8s-1.16.2-Centos7.md

## Join cluster from worker nodes

## Cordon haproxy node on master node so nothing will be scheduled to this special node
```kubectl cordon haproxy1```

## Testing metallb endpoint from haproxy node
```curl http://10.244.1.220/hello -HHost:hello.busyapi.com```

## Install HAProxy
```sudo yum install haproxy -y```

## Configure HAProxy for metallb endpoint
```bash
echo '#---------------------------------------------------------------------
# FrontEnd Configuration for HTTP
#---------------------------------------------------------------------
frontend web80
    bind *:80
    option http-server-close
    option forwardfor
    default_backend app-web80

#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm for HTTP
#---------------------------------------------------------------------
backend app-web80
    balance roundrobin                                     #Balance algorithm
#    option httpchk HEAD / HTTP/1.1\r\nHost:\ localhost    #Check the server application is up and healty - 200 status code
    server node1 10.244.1.220:80 check

#---------------------------------------------------------------------
# FrontEnd Configuration for HTTPS
#---------------------------------------------------------------------
frontend web443
    bind *:443
    option tcplog
    mode tcp
    default_backend app-web443

#---------------------------------------------------------------------
# BackEnd roundrobin as balance algorithm for HTTPS
#---------------------------------------------------------------------
backend app-web443
    mode tcp
    balance roundrobin
    option ssl-hello-chk
    server node1 10.244.1.220:443 check
' | sudo tee -a /etc/haproxy/haproxy.cfg && \
sudo systemctl start haproxy && \
sudo systemctl enable haproxy
```

## Below should work when DNS A record pointing to haproxy node public ip
```curl http://hello.busyapi.com/hello```
* [TROUBLESHOOTING] If you getting connection refused, restart haproxy

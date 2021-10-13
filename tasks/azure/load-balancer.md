## Get Ingress controller NodePort number
```bash
kubectl get svc myingress-ingress-nginx-controller
```

### Output
```bash
NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
myingress-ingress-nginx-controller   LoadBalancer   10.233.43.212   <pending>     80:31760/TCP,443:30778/TCP   14h
```

## Create Load Balancer

### Frontend IP configuration
![image](https://user-images.githubusercontent.com/45472005/137051158-aee11e6b-9346-47bb-b7f3-8b91e65299ff.png)

### Backend pools
![image](https://user-images.githubusercontent.com/45472005/137052551-231a1492-9b2d-4277-a1b3-7af031799879.png)

### Inbound rule for HTTP (port 80) - Part 1
![image](https://user-images.githubusercontent.com/45472005/137052787-4df01219-75b0-439d-b403-1b090b3d423d.png)

### Health probe for HTTP (port 80) - Part 2
![image](https://user-images.githubusercontent.com/45472005/137053148-2fd1c3ea-cd5f-4d3b-90ce-a64240cbbc51.png)

### Repeat above 2 steps to complete for HTTPS (port 443)

### Create Load Balancer
![image](https://user-images.githubusercontent.com/45472005/137053395-37d0c753-a23a-42e7-9cf6-48197abeb2b6.png)

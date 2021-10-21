# ArgoCD

### [Installation](https://github.com/argoproj/argo-cd/releases/latest)

### Check pods and services
```bash
kubectl get pods,svc -n argocd
```

#### Expected everything is Running
![image](https://user-images.githubusercontent.com/45472005/138026674-98de4868-fd3a-42a5-95c5-f3df0fad2560.png)

### Expose service/argocd-server NodePort type
```bash
kubectl patch svc argocd-server --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"}]' -n argocd
```

### Login via NodePort - https://node-ip:30010
```bash
echo username: admin
echo password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
```

### Connect to Helm and Git repo

#### Get Helm repo url
```bash
helm repo list
NAME            URL
stable          https://charts.helm.sh/stable
```

### Connect to a Helm repo
![image](https://user-images.githubusercontent.com/45472005/138028279-ed90582f-1024-4902-b2bc-f36d83c07703.png)
![image](https://user-images.githubusercontent.com/45472005/138028351-304eed15-fd59-47b0-947b-796264764342.png)

### Add Git repo (Bitbucket private instance)

### Your login account
![image](https://user-images.githubusercontent.com/45472005/138028927-76423435-5a07-4f8b-a04d-649a68f026f4.png)
![image](https://user-images.githubusercontent.com/45472005/138029416-f90b2cdd-a2e7-4d3e-8ac1-b0389071094d.png)

#### Create a personal token
![image](https://user-images.githubusercontent.com/45472005/138029717-26beeaa2-0861-44f5-84da-65bfa44fe2cd.png)
![image](https://user-images.githubusercontent.com/45472005/138029793-84791309-a5fa-46d0-a360-a7338a74d3d5.png)

### Connect to a Bitbucket repo
![image](https://user-images.githubusercontent.com/45472005/138031496-284e8ee5-56d7-4be2-8846-5269159c6a47.png)
![image](https://user-images.githubusercontent.com/45472005/138031783-5a1b9c0d-54cf-4984-92fb-938eaa0f5ac9.png)

### Install an application from Helm repo
![image](https://user-images.githubusercontent.com/45472005/138240843-a4aee91d-e3f5-400a-94e7-b2a1e605a630.png)

### OutOfSync
![image](https://user-images.githubusercontent.com/45472005/138241563-e4b637e5-c8fa-412e-82d4-6ece742399d8.png)

### Sync OK
![image](https://user-images.githubusercontent.com/45472005/138241691-954f9770-71df-49f1-ae86-f91f9fd81062.png)

### Make some changes to the deployment (E.g. Increasing replicas)

### OutOfSync -> use app diff to compare the changes
![image](https://user-images.githubusercontent.com/45472005/138242555-c6193f0a-437b-4331-b81f-e50885edb5f1.png)
![image](https://user-images.githubusercontent.com/45472005/138243241-4ed02770-1c10-4024-9098-b0944038c0c6.png)

### Manual sync to make it sync OK

### Turn on auto-sync
![image](https://user-images.githubusercontent.com/45472005/138244088-f6a22cbb-1470-4235-9e8b-e5f1e39591a6.png)

### Increase replicas again

### 

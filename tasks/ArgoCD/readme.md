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

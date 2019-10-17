# alias
```
alias k='kubectl'
alias kdep='kubectl get deployment -o wide --all-namespaces'
alias kpod='kubectl get pod -o wide --all-namespaces'
alias ksvc='kubectl get svc -o wide --all-namespaces'
alias king='kubectl get ingress --all-namespaces'
alias knod='kubectl get node -o wide'
alias klog='kubectl logs'
alias kexe='kubectl exec'
alias kdel='kubectl delete'
alias kwatch='watch kubectl get node,deployment,pod,svc,ing,pv,pvc,sc,sts,job -o wide'
alias gettoken='kubectl describe -n kube-system secret/'
alias c='cat <<EOF | kubectl apply -f -'
```
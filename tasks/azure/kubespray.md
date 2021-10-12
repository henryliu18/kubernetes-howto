# Setting up Ansible kubespray environment from workstation vm

## bash into alpine-ansible
```bash
sudo docker run --rm -it -w /home/alpine woahbase/alpine-ansible bash
```

## kubespray
```bash
apk update && \
apk add gcc && \
apk add git && \
apk add python3-dev && \
apk add musl-dev && \
apk add libffi-dev && \
apk add openssl-dev && \
/usr/bin/python3.7 -m pip install --upgrade pip && \
git clone https://github.com/kubernetes-sigs/kubespray.git && \
pip3 uninstall ansible -y && \
pip3 install -r $PWD/kubespray/requirements.txt
```

## configure project
```bash
cd kubespray
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
declare -a IPS=(10.0.0.4 10.0.0.5)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

## copy ssh private key to /tmp
```bash
vi /tmp/key
```

## add known_hosts
```bash
chmod 700 /tmp/key
ssh -i /tmp/key azureuser@10.0.0.4 uptime
```

```bash
ssh -i /tmp/key azureuser@10.0.0.5 uptime
```

## configure /etc/ansible/hosts
```bash
echo 'node1 ansible_host=10.0.0.4 ansible_user=azureuser
node2 ansible_host=10.0.0.5 ansible_user=azureuser' > /etc/ansible/hosts
```

## flannel - find kube_network_plugin: calico -> replace with kube_network_plugin: flannel
```bash
vi inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

## containerd - find container_manager: docker -> replace with container_manager: containerd
```bash
vi inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

## containerd - find etcd_deployment_type: docker -> replace with etcd_deployment_type: host
```bash
vi inventory/mycluster/group_vars/etcd.yml
```

## containerd - append below code block to containerd.yml
```bash
echo 'containerd_registries:
  "docker.io":
    - "https://mirror.gcr.io"
    - "https://registry-1.docker.io"' >> inventory/mycluster/group_vars/all/containerd.yml
```
## node placement - modify preferred nodes for control plane/node/etcd...
```bash
vi inventory/mycluster/hosts.yaml
```
## play runbook
```bash
/usr/bin/ansible-playbook --flush-cache -i /home/alpine/kubespray/inventory/mycluster/hosts.yaml  --become --become-user=root --private-key="/tmp/key" -e ansible_user=azureuser /home/alpine/kubespray/cluster.yml
```

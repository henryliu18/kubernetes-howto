# Kubernetes installation and cluster creation using Kubespray

## (option 1: build your own ansible runtime) run ubuntu:22.04 on the same network as nodes
```bash
sudo docker run --rm -it ubuntu:22.04
```
## (option 1) Setup library - python3/ansible/git
```bash
apt update
add-apt-repository --yes --update ppa:ansible/ansible
apt install git software-properties-common ansible python3-pip -y
```

## (option 2: prebuilt) run jfxs/ansible on the same network as nodes
```bash
sudo docker run --rm -it --user root jfxs/ansible sh
```

## (option 2) install bash then open a bash shell
```bash
apk add bash; bash
```

## Constants
```bash
#The user on the target servers configured for ssh and sudo.  E.g. ubuntu/azureuser/ec2user/opc depending on cloud providers
K8S_INSTALLATION_USER="henry"
SUDO_PASSWORD="1234"
#Target IPs
declare -a IPS="(10.0.0.4 10.0.0.5)"
#Numbers of indexes in IPS
tLen=${#IPS[@]}
```

## create ssh private key for ssh connection
```bash
ssh-keygen -b 2048 -t rsa -q -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa > /tmp/key
chmod 700 /tmp/key
```

## update authorized_keys to all nodes
```bash
for (( i=0; i<${tLen}; i++ ));
do
  ssh-copy-id ${K8S_INSTALLATION_USER}@${IPS[$i]}
done
```

## kubespray configure
```bash
git clone https://github.com/kubernetes-sigs/kubespray.git
pip3 install -r $PWD/kubespray/requirements.txt
```

## mycluster configure
```bash
cd kubespray
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```

## configure /etc/ansible/hosts
```bash
#echo "node1 ansible_host=10.0.0.4 ansible_user=$K8S_INSTALLATION_USER
#node2 ansible_host=10.0.0.5 ansible_user=$K8S_INSTALLATION_USER" > /etc/ansible/hosts
mkdir -p /etc/ansible
>/etc/ansible/hosts
for (( i=0; i<${tLen}; i++ ));
do
  k=$(expr ${i} + 1)
  echo "node${k} ansible_host=${IPS[$i]} ansible_user=${K8S_INSTALLATION_USER}" >> /etc/ansible/hosts
done
```

## (optional) flannel - find kube_network_plugin: calico -> replace with kube_network_plugin: flannel
```bash
sed -i 's/kube_network_plugin: calico/kube_network_plugin: flannel/g' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

## (optional validation) node placement - modify preferred nodes for control plane/node/etcd...
```bash
vi inventory/mycluster/hosts.yaml
```
## play runbook - create cluster
```bash
# kube_version variable to overwrite the default latest kube_version
ansible-playbook --flush-cache -i ./inventory/mycluster/hosts.yaml \
--become --become-user="root" --private-key="/tmp/key" -e ansible_user=$K8S_INSTALLATION_USER \
-e ignore_assert_errors="yes" --extra-vars "ansible_sudo_pass=${SUDO_PASSWORD}" \
./cluster.yml -e kube_version="v1.26.2"
```

## play runbook - upgrade cluster
```bash
ansible-playbook --flush-cache -i ./inventory/mycluster/hosts.yaml \
--become --become-user="root" --private-key="/tmp/key" -e ansible_user=$K8S_INSTALLATION_USER \
-e ignore_assert_errors="yes" --extra-vars "ansible_sudo_pass=${SUDO_PASSWORD}" \
./upgrade-cluster.yml -e kube_version="v1.26.2"
```

## play runbook - destroy cluster
```bash
ansible-playbook --flush-cache -i ./inventory/mycluster/hosts.yaml \
--become --become-user="root" --private-key="/tmp/key" -e ansible_user=$K8S_INSTALLATION_USER \
-e ignore_assert_errors="yes" --extra-vars "ansible_sudo_pass=${SUDO_PASSWORD}" \
./reset.yml
```

## expected output of playbook
```bash
PLAY RECAP **********************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
node1                      : ok=523  changed=118  unreachable=0    failed=0    skipped=1090 rescued=0    ignored=2
node2                      : ok=326  changed=75   unreachable=0    failed=0    skipped=594  rescued=0    ignored=1

Tuesday 12 October 2021  11:08:34 +0000 (0:00:00.094)       0:08:44.973 *******
===============================================================================
kubernetes/preinstall : Install packages requirements ------------------------------------------------------------------------------------------- 40.18s
kubernetes/kubeadm : Join to cluster ------------------------------------------------------------------------------------------------------------ 24.63s
kubernetes/control-plane : kubeadm | Initialize first master ------------------------------------------------------------------------------------ 19.31s
download : download_container | Download image if required -------------------------------------------------------------------------------------- 13.35s
download : download_container | Download image if required -------------------------------------------------------------------------------------- 12.86s
kubernetes/preinstall : Update package management cache (APT) ----------------------------------------------------------------------------------- 11.34s
download : download_container | Download image if required -------------------------------------------------------------------------------------- 10.72s
container-engine/containerd : ensure containerd packages are installed --------------------------------------------------------------------------- 9.81s
download : download_container | Download image if required --------------------------------------------------------------------------------------- 9.35s
kubernetes/control-plane : Master | wait for kube-scheduler -------------------------------------------------------------------------------------- 7.15s
download : download_container | Download image if required --------------------------------------------------------------------------------------- 6.94s
download : download_container | Download image if required --------------------------------------------------------------------------------------- 6.90s
container-engine/crictl : download_file | Download item ------------------------------------------------------------------------------------------ 6.59s
download : download_container | Download image if required --------------------------------------------------------------------------------------- 6.51s
kubernetes-apps/ansible : Kubernetes Apps | Start Resources -------------------------------------------------------------------------------------- 5.81s
container-engine/crictl : extract_file | Unpacking archive --------------------------------------------------------------------------------------- 5.63s
download : download | Download files / images ---------------------------------------------------------------------------------------------------- 5.61s
download : download_file | Download item --------------------------------------------------------------------------------------------------------- 5.42s
container-engine/containerd : ensure containerd repository is enabled ---------------------------------------------------------------------------- 5.34s
etcd : Configure | Check if etcd cluster is healthy ---------------------------------------------------------------------------------------------- 5.28s
```

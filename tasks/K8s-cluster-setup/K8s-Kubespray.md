# K8s software installation (control plane and worker) using Kubespray

## Environment
### ansible host - requiring python3/pip3/ansible/git
### node1 - master/worker
### node2 - master/worker
### node3 - worker

#### Replacing IP addresses of all your K8s hosts
```bash
declare -a ALLIPS=()

# Example
declare -a ALLIPS=(192.168.56.152 192.168.56.153 192.168.56.154)
```

### Ansible host
```bash
# python3 and pip3
yum install -y https://centos7.iuscommunity.org/ius-release.rpm && \
yum install -y python36u python36u-libs python36u-devel python36u-pip

# ansible
yum -y install epel-release && \
yum -y install ansible

# git
yum -y install git

# ssh keygen and copy to all hosts
ssh-keygen && \
tLen=${#ALLIPS[@]} && \
for (( i=0; i<${tLen}; i++ ));
do
  ssh-copy-id root@${ALLIPS[$i]}
done

# adding hosts to ansible hosts file
echo "[servers]" >> /etc/ansible/hosts && \
for (( i=0; i<${tLen}; i++ ));
do
  echo "node${i} ansible_host=${ALLIPS[$i]} ansible_user=root" >> /etc/ansible/hosts
done

# disable firewalld using ansible
ansible -m shell -a 'systemctl stop firewalld' all
ansible -m shell -a 'systemctl disable firewalld' all

# clone, configure Kubespray and create copy of a cluster inventory
git clone https://github.com/kubernetes-sigs/kubespray.git && \
cd kubespray && \
pip3 install -r requirements.txt && \
cp -rfp inventory/sample inventory/mycluster

# define ips and inventory to create yaml
IPS=("${ALLIPS[@]}")
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

# run playbook
ansible-playbook --flush-cache -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
```

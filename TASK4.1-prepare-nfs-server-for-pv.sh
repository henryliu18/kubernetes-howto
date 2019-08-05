#!/bin/bash

#Example of NFS server/client build

#BEGIN
NFS_SERVER='k8s-master'
NFS_SHARE='/nfsshare'

#TCP/UDP 111 and 2049 must be allowed

#NFS SERVER BUILD
sudo apt install nfs-kernel-server
sudo mkdir ${NFS_SHARE}
sudo chmod 777 ${NFS_SHARE}
echo -e "${NFS_SHARE} *(rw,sync,no_subtree_check,insecure)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server
sudo exportfs -rav
sudo exportfs -v

#NFS CLIENT BUILD
sudo apt-get install nfs-common
sudo mount -t nfs ${NFS_SERVER}:${NFS_SHARE} /mnt
#END

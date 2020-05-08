#!/bin/bash

#initial VM setup

#TODO LIST
# get number of nodes from command line
# get cpu / ran / disk size for primary from command line with sensible defaults
# get cpu / ram / disk size for nodes from command line with sensible defaults
# check if nodes with same name as what will be built already exist and quit with a warning
# install cluster with kubeadm
# install metallb - and ask for what IP range should be shared - with sensible defaults
# install local-path default storage path from rancher
# install KOV and setup to use LB
# add a delete option to specifiy a cluster name and delete all multipass nodes including that name, and delete them

# check if multipass installed and quit if not
command -v multipass >/dev/null 2>&1 || { echo >&2 "Please install multipass on your system before proceeding. https://multipass.run"; exit 1; }
MPASS=`command -v multipass`
echo "We will use $MPASS to run this script. Proceeding..." 

# get a unique cluster name from command line entry
read -p "Please enter a name for your cluster:" CLUSTERNAME
while [[ "$CLUSTERNAME" =~ [^a-zA-Z] ]] ; do
  echo "invalid cluster Name - please use alpha chars only"
  read -p "Please enter a name for your cluster:" CLUSTERNAME
done
echo "We will proceed with $CLUSTERNAME to identify VMs brought up with this script" 

exit
SHAREPATH="$PWD/multipass"


#provision VMs with multipass and install prereqs for K8s
for s in primary node1 node2 node3
do
  multipass launch --name $s --cpus 2 --mem 2048M --disk 10G
  multipass mount $SHAREPATH "$s:/multipass"
  multipass exec $s -- sudo /multipass/initial_pkg_install.sh
done

#install control plane on master node
multipass exec primary -- /multipass/provision_master.sh

#install kubelet worker nodes
for t in node1 node2 node3
do 
  multipass exec $t -- sudo /multipass/join.sh
done

#install metallb on cluster
multipass exec primary -- /multipass/setup_lb.sh

#!/bin/bash

#initial VM setup

#TODO LIST
# check if multipass installed
# get a unique cluster name from command line entry
# get number of nodes from command line
# get cpu / ran / disk size for primary from command line with sensible defaults
# get cpu / ram / disk size for nodes from command line with sensible defaults
# check if nodes with same name as what will be built already exist and quit with a warning
# install cluster with kubeadm
# install metallb - and ask for what IP range should be shared - with sensible defaults
# install local-path default storage path from rancher
# install KOV and setup to use LB
# add a delete option to specifiy a cluster name and delete all multipass nodes including that name, and delete them






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

#!/bin/bash

#initial VM setup

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

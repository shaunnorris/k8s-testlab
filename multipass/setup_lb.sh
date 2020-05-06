#!/bin/sh

#should be run from primary node after worker nodes have joined
# Configure metalLB
kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.8.3/manifests/metallb.yaml

#edit this file if you want to change the range of public IPs for ingress LBs
kubectl apply -f /multipass/metallb.yaml

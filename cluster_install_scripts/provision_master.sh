#remvoe previous join-file from any previous installs
OUTPUT_FILE=/vagrant/k8s-testlab/join.sh
rm -rf $OUTPUT_FILE

# Start cluster
sudo kubeadm init --apiserver-advertise-address=10.0.0.10 --pod-network-cidr=10.244.0.0/16 | grep -A 2 "kubeadm join" > ${OUTPUT_FILE}
chmod +x $OUTPUT_FILE

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Fix kubelet IP
echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=10.0.0.10"' | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Configure Calico
echo "\n*** install Calico\n"
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

# Configure flannel
#curl -o kube-flannel.yml https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
#sed -i.bak 's|"/opt/bin/flanneld",|"/opt/bin/flanneld", "--iface=enp0s8",|' kube-flannel.yml
#kubectl create -f kube-flannel.yml

sudo systemctl daemon-reload
sudo systemctl restart kubelet
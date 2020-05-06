#remvoe previous join-file from any previous installs
OUTPUT_FILE=/multipass/join.sh
rm -rf $OUTPUT_FILE

PRIMARYIP=`hostname -I | cut -d' ' -f1`
# Start cluster
sudo kubeadm init --apiserver-advertise-address=${PRIMARYIP} --pod-network-cidr=10.244.0.0/16 | grep -A 2 "kubeadm join" > ${OUTPUT_FILE}
chmod +x $OUTPUT_FILE

# Configure kubectl
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Fix kubelet IP
echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=${PRIMARYIP}\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

# Configure Calico
echo "\n*** install Calico\n"
kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml

sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Configure metalLB


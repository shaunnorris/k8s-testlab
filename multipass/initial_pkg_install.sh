export DEBIAN_FRONTEND=noninteractive

# bridged traffic to iptables is enabled for kube-router.
cat >> /etc/ufw/sysctl.conf <<EOF
net/bridge/bridge-nf-call-ip6tables = 1
net/bridge/bridge-nf-call-iptables = 1
net/bridge/bridge-nf-call-arptables = 1
EOF

# disable swap
echo "***SWAP OFF***"
swapoff -a
sed -i '/swap/d' /etc/fstab

#install some more stuff
echo "***Install ebtables***"
apt-get  install -y ebtables 
#apt-get  install -y  apt-transport-https curl

# Install Docker CE
## Set up the repository:
### Install packages to allow apt to use a repository over HTTPS
echo "***Install ca-certificates and software-properties-common***"
apt-get update && apt-get install -y ca-certificates software-properties-common

### Add Docker’s official GPG key
echo "***Install Docker GPG key*** "
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
echo "***Install Docker repo *** "
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

## Install Docker CE.
echo "***Install Docker CE and setup daemon*** "
apt-get update && apt-get -y install docker-ce=18.06.2~ce~3-0~ubuntu

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

#setup k8s repo and install packageds
echo "***Install add google GPG key*** "
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

echo "*** install kubernetes packages to sources.list*** "
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
echo "*** install kubernetes packages *** "
apt-get update && apt-get install -y kubelet kubeadm kubectl

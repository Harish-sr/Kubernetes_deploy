# set the force to off
setenforce 0
#disable SELINUX on the host
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# allow only the following below ports on the firewall
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
modprobe br_netfilter

# set 1 for the iptables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

#swap turn off
swapoff -a




# install kubernetes and docker
yum install kubeadm docker -y

# start docker and enable the same
systemctl restart docker && systemctl enable docker
# start kubelet and enable
systemctl  restart kubelet && systemctl enable kubelet

########################init kubernetes####################
kubeadm init


mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"





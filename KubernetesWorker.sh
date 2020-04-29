# set the force to off
setenforce 0
# disable SELINUX on the host
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
# allow only the below ports on the firewall
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --permanent --add-port=30000-32767/tcp
firewall-cmd --permanent --add-port=6783/tcp
firewall-cmd  --reload
# set 1 in the IP tables
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
# swap needs to be turned off
swapoff -a
# install the kubernetes and docker
yum  install kubeadm docker -y
#start tje docker and enable it
systemctl restart docker && systemctl enable docker
# start the kubelet and enable it
systemctl  restart kubelet && systemctl enable kubelet


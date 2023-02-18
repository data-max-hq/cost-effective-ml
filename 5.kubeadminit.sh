IPADDR="10.128.0.24"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

sudo kubeadm init --apiserver-advertise-address=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME
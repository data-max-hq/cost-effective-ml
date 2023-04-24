# Create organization tags

# Create firewall rule
#

# Create instances with tags
# 4 CPU 16 GB 100 GB
sudo apt-get update -y && sudo apt-get upgrade -y

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update

sudo apt-get install apt-transport-https git helm -y

# install customize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /bin/

## Prepare registries
sudo mkdir -p /etc/rancher/k3s
sudo vi /etc/rancher/k3s/registries.yaml

# server
sudo systemctl restart k3s
# restart agent
sudo systemctl restart k3s-agent

# Install k3s main, only in master
# curl -sfL https://get.k3s.io | sh -
--node-external-ip=34.31.109.232 --flannel-backend=wireguard-native --flannel-external-ip
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 INSTALL_K3S_EXEC="--node-external-ip=34.31.109.232 --flannel-backend=wireguard-native --flannel-external-ip" sh -

# Get node token
# sudo cat /var/lib/rancher/k3s/server/node-token
export K3S_NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Add agent nodes
SERVER_IP=10.128.0.42
SERVER_IP=34.31.109.232
K3S_NODE_TOKEN=K10f7d0ceaf25e86b0148939a78542c4acfcf0828f17930161b9ee95a76fe854378::server:02315bc502e917c3962303f6141bfb71
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} INSTALL_K3S_EXEC="--node-external-ip=147.189.197.1" sh -

SERVER_IP=34.31.109.232
K3S_NODE_TOKEN=K10f7d0ceaf25e86b0148939a78542c4acfcf0828f17930161b9ee95a76fe854378::server:02315bc502e917c3962303f6141bfb71
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} INSTALL_K3S_EXEC="--node-external-ip=147.189.196.95" sh -

SERVER_IP=34.31.109.232
K3S_NODE_TOKEN=K10f7d0ceaf25e86b0148939a78542c4acfcf0828f17930161b9ee95a76fe854378::server:02315bc502e917c3962303f6141bfb71
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} INSTALL_K3S_EXEC="--node-external-ip=35.193.173.186" sh -

# Dashboard
# https://docs.k3s.io/installation/kube-dashboard
GITHUB_URL=https://github.com/kubernetes/dashboard/releases
VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml

vi user.yaml
vi role.yaml

sudo k3s kubectl create -f user.yaml -f role.yaml

sudo k3s kubectl -n kubernetes-dashboard create token admin-user

sudo k3s kubectl port-forward svc/kubernetes-dashboard  -n kubernetes-dashboard 8443:443 --address='0.0.0.0'

## Add node labels
sudo k3s kubectl get nodes --show-labels
sudo k3s kubectl label nodes k3s-instance-2 cpu=true
sudo k3s kubectl label nodes k3s-instance-3 cpu=true
sudo k3s kubectl label nodes k3s-instance-4 gpu=true
sudo k3s kubectl label nodes k3s-instance-5 gpu=true

## install kuberay operator

# Kubeflow UI
export PIPELINE_VERSION=1.8.5
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
sudo k3s kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"


sudo k3s kubectl port-forward svc/ml-pipeline-ui  -n kubeflow 8080:80 --address='0.0.0.0'

##install kubeflow
#git clone https://github.com/kubeflow/manifests.git
git clone https://github.com/data-max-hq/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sudo k3s kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

# enable unsecure
# https://github.com/kubeflow/manifests#change-default-user-password
https://github.com/kubeflow/manifests/pull/2155
https://github.com/kubeflow/manifests/issues/2225#issuecomment-1157931840

# Change username password
https://github.com/kubeflow/manifests#change-default-user-password

# delete kubeflow
kustomize build example | sudo k3s kubectl delete -f -

sudo k3s kubectl port-forward svc/demo-cluster-head-svc  8625:8625 --address='0.0.0.0'

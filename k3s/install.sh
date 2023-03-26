# Create organization tags

# Create firewall rule
#

# Create instances with tags
# 4 CPU 16 GB
sudo apt-get update -y
sudo apt-get install git -y

# Install k3s main
curl -sfL https://get.k3s.io | sh -

# Get node token
#sudo cat /var/lib/rancher/k3s/server/node-token
export K3S_NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Add agent nodes
SERVER_IP=10.128.0.29
K3S_NODE_TOKEN=K10853a6fab88d417f95525b95def3d9838d6310a97294f8bb92344c7d020135da0::server:8fcb59ef2de5160d475fb0cf8440b3d6
curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -

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

# Kubeflow UI

sudo k3s kubectl port-forward svc/ml-pipeline-ui  -n kubeflow 8080:80 --address='0.0.0.0'
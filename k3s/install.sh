# Create organization tags

# Create firewall rule
#

# Create instances with tags
# 4 CPU 16 GB 100 GB
sudo apt-get update -y
sudo apt-get install git -y

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

# Install k3s main
curl -sfL https://get.k3s.io | sh -

# Get node token
#sudo cat /var/lib/rancher/k3s/server/node-token
export K3S_NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Add agent nodes
SERVER_IP=10.128.0.29
K3S_NODE_TOKEN=
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
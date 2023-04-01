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

# Install k3s main, only in master
curl -sfL https://get.k3s.io | sh -

# Get node token
#sudo cat /var/lib/rancher/k3s/server/node-token
export K3S_NODE_TOKEN=$(sudo cat /var/lib/rancher/k3s/server/node-token)

# Add agent nodes
SERVER_IP=10.128.0.35
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
export PIPELINE_VERSION=1.8.5
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
sudo k3s kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"


sudo k3s kubectl port-forward svc/ml-pipeline-ui  -n kubeflow 8080:80 --address='0.0.0.0'

##install kubeflow
git clone https://github.com/kubeflow/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sudo k3kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:8080 --address='0.0.0.0'

##
sudo mkdir /etc/rancher/k3s
sudo vi /etc/rancher/k3s/registries.yaml

# server
sudo systemctl restart k3s
# restart agent
sudo systemctl restart k3s-agent


sudo k3s kubectl port-forward svc/demo-cluster-head-svc  8625:8625 --address='0.0.0.0'
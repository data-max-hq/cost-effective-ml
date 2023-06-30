# Install requirements
sudo apt-get update -y && sudo apt-get upgrade -y

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

sudo apt-get install apt-transport-https git make -y

# install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /bin/

# Install nvidia-container-toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit


# Install k3s
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

# Install GPU Operator
sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && sudo helm repo update

sudo helm upgrade --install --wait gpu-operator \
     --namespace gpu-operator \
     --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false \
      --kubeconfig /etc/rancher/k3s/k3s.yaml

# Check installation

#sudo helm list -n gpu-operator --kubeconfig /etc/rancher/k3s/k3s.yaml
#sudo helm uninstall gpu-operator -n gpu-operator --kubeconfig /etc/rancher/k3s/k3s.yaml
sudo kubectl get po -n gpu-operator

sudo kubectl describe nodes

# - Install nvidia K8S Device plugin
#sudo helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
#  sudo helm repo update
#  sudo helm upgrade -i nvdp nvdp/nvidia-device-plugin \
#  --namespace nvidia-device-plugin \
#  --create-namespace \
#  --version 0.14.0 \
#  --kubeconfig /etc/rancher/k3s/k3s.yaml
#
## check installation
#sudo kubectl get po -n nvidia-device-plugin
#
#sudo helm uninstall nvdp -n nvidia-device-plugin --kubeconfig /etc/rancher/k3s/k3s.yaml


# Install Kubeflow
git clone https://github.com/data-max-hq/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sudo kubectl get po -n kubeflow

sudo kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

# Install kuberay-operator
sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
sudo helm repo update
sudo helm upgrade --install \
  kuberay-operator kuberay/kuberay-operator \
  --version 0.5.0 \
  --kubeconfig /etc/rancher/k3s/k3s.yaml

# Check the KubeRay operator Pod in `default` namespace
sudo k3s kubectl get pods

sudo k3s kubectl get svc


#Install cluster
sudo kubectl apply -f cluster.yaml

sudo k3s kubectl port-forward --address 0.0.0.0 svc/example-cluster-head-svc 8265:8265 -n kubeflow-user-example-com


sudo kubectl exec -it -n kubeflow-user-example-com example-cluster-head-7ddxf -- /bin/bash

wget https://raw.githubusercontent.com/ray-project/ray/94062557ffea29530da236a7700d51e511f61906/python/ray/train/examples/tf/tensorflow_mnist_example.py

time python tensorflow_mnist_example.py --num-workers 2 --use-gpu True --epochs 3

# Install agent nodes
sudo cat /var/lib/rancher/k3s/server/node-token

SERVER_IP=192.168.17.171
K3S_NODE_TOKEN=K104c90d5cec4a63e8ac012057d0dc605d7a1be06b87244ddcf82a569dabd354a2a::server:76d1e6d0c864210a1c81827a93334c0f
curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -

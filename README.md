# Cost Effective ML
Building a Multi GPU Kubernetes Cluster for Scalable and Cost-Effective ML Training with Ray and Kubeflow. 
Related blog post [here](https://www.data-max.io/post/multigpu-kubernetes-cluster-for-scalable-and-cost-effective-machine-learning-with-ray-and-kubeflow).

## Building the Multi GPU Kubernetes Cluster
![1-setup.png](diagrams/images/1-setup.png)

## What we will be doing:
1. Create one CPU node and two GPU nodes
2. Create a Kubernetes cluster and add the nodes in cluster
3. Enable Kubernetes dashboard
4. Install NVIDIA GPU Operator
5. Check GPUs are available in the cluster
6. Install KubeRay
7. Create a Ray Cluster
8. Enable Ray dashboard
9. Run Ray workload in Kubeflow

## Prerequisites
These tools must be installed in the nodes before starting:
* Git
* Helm3
* Kustomize
* Make
* Nvidia Container Runtime

### Versions tested in the demo
* Kubernetes 1.25
* Python 3.8
* Ray 2.6
* Kubeflow 1.7
* Ubuntu 20.04
* KubeRay 0.6.0
* NVIDIA GPU Operator v23.6.0
* Demo tested on Genesis Cloud with NVIDIA RTX3090 GPUs

## How to set up K3S master node

### Install prerequisites
#### Install common utilities
```commandline
sudo apt-get install apt-transport-https git make -y
```

#### Install `helm`
```sh
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
   && chmod 700 get_helm.sh \
   && ./get_helm.sh
```

#### Install `kustomize`
```sh
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /bin/
```

### Install Kubernetes
#### Install `K3S` on the main node
```
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -
```

#### Run `kubectl` without sudo
```sh
sudo chown $USER /etc/rancher/k3s/k3s.yaml
```

## Kubernetes worker nodes setup

### Install prerequisites
#### (If node contains GPUs) Make sure NVIDIA drivers are installed
Check by running:
```sh
nvidia-smi
```

#### Install `Nvidia Container Runtime`
```sh
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit
```

### Installing `K3S` agents on worker nodes

#### From the main node get the node token
```sh
sudo cat /var/lib/rancher/k3s/server/node-token on master node
```

#### Run the `K3S` installation command on the worker nodes
```sh
export K3S_NODE_TOKEN=NODE_TOKEN
export SERVER_IP=(Public/Private IP of master node)
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -
```

## Install NVIDIA GPU Operator from the main node

NVIDIA GPU Operator allows the cluster to have access to GPUs in nodes. 
It installs the necessary tools to make the GPUs accessible for Kubernetes.

More on [nvidia-gpu-operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/overview.html)

```
sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && sudo helm repo update

sudo helm install --wait --generate-name \
     -n gpu-operator --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false \
      --kubeconfig /etc/rancher/k3s/k3s.yaml  
```

## Usage/Examples

You can play around with GPUs by using Jupyter Notebook.

### Install Kubeflow
#### Install Kubeflow
```sh
git clone https://github.com/data-max-hq/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done
```

#### Check Kubeflow installation status:
```sh
sudo kubectl get po -n kubeflow
```

#### After Kubeflow is installed, expose the Kubeflow UI:
```sh
kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'
```

### Create Ray Cluster
#### Install KubeRay Operator
```sh
sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
sudo helm repo update
sudo helm upgrade --install \
    kuberay-operator kuberay/kuberay-operator \
    --namespace kuberay-operator \
    --create-namespace \
    --version 0.6.0 \
    --kubeconfig /etc/rancher/k3s/k3s.yaml
```

#### Check the Operator Installation
```sh
sudo kubectl get pods -n kuberay-operator
```

#### Create Ray Cluster
```sh
sh ray-cluster.sh
```

## Troubleshooting
* Configure private registries in k3s: https://docs.k3s.io/installation/private-registry
  * https://breadnet.co.uk/using-google-artifact-registry-with-k3s/
* Restart k3s and k3s-agent: https://docs.k3s.io/upgrades/manual#restarting-k3s
* Restart k3s and k3s-agent if command ```kubectl describe node *gpu-node*``` does not show nvidia.com/gpu resource


## Links 
* https://cloud.google.com/blog/products/ai-machine-learning/build-a-ml-platform-with-kubeflow-and-ray-on-gke
* https://github.com/ray-project/kuberay
* https://docs.ray.io/en/latest/cluster/kubernetes/examples/gpu-training-example.html#kuberay-gpu-training-example
* https://ray-project.github.io/kuberay/deploy/helm/
* https://docs.ray.io/en/latest/train/train.html
* https://github.com/NVIDIA/gpu-operator


Made with ❤️ by [datamax.ai](https://www.datamax.ai/).

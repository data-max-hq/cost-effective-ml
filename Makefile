.PHONY: ssh req check-node nvidia-container-toolkit check-toolkit k3s get-k3s-node-token k3s-agents check-nodes gpu-operator check-gpu-operator describe-nodes kubeflow check-kubeflow kubeflow-port kuberay check-kuberay raycluster check-raycluster raycluster-port uninstall uninstall-agent

# Variables
K3S_VERSION?=v1.26.7+k3s1
SERVER_IP?=192.168.11.120
#K3S_VERSION?=v1.25.8+k3s1

ssh:
	ssh ubuntu@147.189.198.9

req:
	# Install requirements
	sudo apt-get update -y && sudo apt-get upgrade -y && \
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh && \
	sudo apt-get install apt-transport-https git make -y && \
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
	sudo mv kustomize /bin/

check-node:
	nvidia-smi

nvidia-container-toolkit:
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

check-toolkit:
	nvidia-container-toolkit --version

k3s:
	curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=$(K3S_VERSION) sh -

get-k3s-node-token:
	sudo cat /var/lib/rancher/k3s/server/node-token

k3s-agents:
	SERVER_IP=192.168.11.120
	K3S_NODE_TOKEN=
	curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} INSTALL_K3S_VERSION=$(K3S_VERSION) sh -

check-nodes:
	sudo kubectl get nodes

#k3sdashboard:
#	chmod +x k3s-dashboard.sh
#	./k3s-dashboard.sh
#
#token:
#	sudo k3s kubectl -n kubernetes-dashboard create token admin-user
#
#k3sdashboard-port:
#	sudo k3s kubectl port-forward svc/kubernetes-dashboard  -n kubernetes-dashboard 8443:443 --address='0.0.0.0'

gpu-operator:
	sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   	&& sudo helm repo update \
	&& sudo helm upgrade --install --wait gpu-operator \
		--namespace gpu-operator \
		--create-namespace \
		nvidia/gpu-operator \
		--set driver.enabled=false \
		--set toolkit.enabled=false \
		--kubeconfig /etc/rancher/k3s/k3s.yaml

check-gpu-operator:
	sudo kubectl get po -n gpu-operator

describe-nodes:
	sudo kubectl describe nodes
	#sudo kubectl describe nodes k3s-instance-1

kubeflow:
	git clone https://github.com/data-max-hq/manifests.git
	cd manifests/
	while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

check-kubeflow:
	sudo kubectl get po -n kubeflow

kubeflow-port:
	sudo kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

kuberay:
	sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
	sudo helm repo update
	sudo helm upgrade --install \
  	kuberay-operator kuberay/kuberay-operator \
  	--namespace kuberay-operator \
    --create-namespace \
  	--version 0.6.0 \
  	--kubeconfig /etc/rancher/k3s/k3s.yaml

check-kuberay:
	sudo kubectl get pods -n kuberay-operator

raycluster:
	#Create Ray cluster
	sudo sh ray-cluster.sh
	#sudo kubectl apply -f k3s/ray-cluster.yaml
	#sudo kubectl apply -f https://raw.githubusercontent.com/data-max-hq/cost-effective-ml/main/k3s/ray-cluster.yaml

check-raycluster:
	sudo kubectl get pods -n kubeflow-user-example-com

raycluster-port:
	sudo kubectl port-forward --address 0.0.0.0 svc/example-cluster-head-svc 8265:8265 -n kubeflow-user-example-com

uninstall:
	/usr/local/bin/k3s-uninstall.sh

uninstall-agent:
	/usr/local/bin/k3s-uninstall.sh
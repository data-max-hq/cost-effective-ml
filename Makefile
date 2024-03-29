.PHONY: req check-node nvidia-container-toolkit check-toolkit k3s get-k3s-node-token k3s-agents check-nodes gpu-operator check-gpu-operator describe-nodes kubeflow check-kubeflow kubeflow-port kuberay check-kuberay raycluster check-raycluster raycluster-port uninstall uninstall-agent

# git clone https://github.com/data-max-hq/cost-effective-ml.git
# Variables
#K3S_VERSION?=v1.25.8+k3s1
KUBERAY_VERSION?=0.6.0
GPU_OPERATOR_VERSION?=v23.6.0

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
#	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#	&& curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
#	&& curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
#	&& sudo apt-get update \
#	&& sudo apt-get install -y nvidia-container-toolkit
	distribution=$$(. /etc/os-release;echo $$ID$$VERSION_ID) \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
	&& curl -s -L https://nvidia.github.io/libnvidia-container/$$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
	&& sudo apt-get update \
	&& sudo apt-get install -y nvidia-container-toolkit

check-toolkit:
	nvidia-container-toolkit --version

k3s:
	curl -sfL https://get.k3s.io | K3S_TOKEN=12345 INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

su-kubectl:
	sudo chown $$USER /etc/rancher/k3s/k3s.yaml

get-k3s-node-token:
	sudo cat /var/lib/rancher/k3s/server/node-token

k3s-agents:
	SERVER_IP=192.168.8.27
	#K3S_NODE_TOKEN=
	curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=12345 INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

check-nodes:
	sudo kubectl get nodes

dashboard:
	helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/ \
   	&& helm repo update \
	&& helm upgrade --install kubernetes-dashboard \
	kubernetes-dashboard/kubernetes-dashboard \
	--create-namespace \
	--namespace kubernetes-dashboard \
	--version 7.0.3 \
	--set metrics-server.enabled=false \
	--set nginx.enabled=false \
	--set cert-manager.enabled=false \
	--kubeconfig /etc/rancher/k3s/k3s.yaml

# kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-nginx-controller 8443:443 --address 0.0.0.0
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
#	helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
#	&& helm repo update \
#	&& helm upgrade --install --wait gpu-operator \
#		--namespace gpu-operator \
#		--create-namespace \
#		nvidia/gpu-operator \
#		--version v23.6.0 \
#		--set driver.enabled=false \
#		--set toolkit.enabled=false \
#		--kubeconfig /etc/rancher/k3s/k3s.yaml
	helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
	&& helm repo update \
	&& helm upgrade --install --wait gpu-operator \
		--namespace gpu-operator \
		--create-namespace \
		nvidia/gpu-operator \
		--version ${GPU_OPERATOR_VERSION} \
		--set driver.enabled=false \
		--set toolkit.enabled=false \
		--kubeconfig /etc/rancher/k3s/k3s.yaml

gpu-operator-check:
	kubectl get po -n gpu-operator

describe-nodes:
	kubectl describe nodes
	#sudo kubectl describe nodes k3s-instance-1

kubeflow:
	git clone https://github.com/data-max-hq/manifests.git	\
	&& cd manifests/ \
	&& while ! kustomize build example | awk '!/well-defined/' | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

kubeflow-check:
	kubectl get po -n kubeflow

kubeflow-port:
	kubectl port-forward svc/istio-ingressgateway 8080:80 -n istio-system --address 0.0.0.0

kuberay:
#	helm repo add kuberay https://ray-project.github.io/kuberay-helm/ \
#	&& helm repo update \
# 	&& helm upgrade --install \
#	kuberay-operator kuberay/kuberay-operator \
#	--namespace kuberay-operator \
#	--create-namespace \
#	--version 0.6.0 \
#	--kubeconfig /etc/rancher/k3s/k3s.yaml
	helm repo add kuberay https://ray-project.github.io/kuberay-helm/ \
   	&& helm repo update \
   	&& helm upgrade --install \
	kuberay-operator kuberay/kuberay-operator \
	--namespace kuberay-operator \
	--create-namespace \
	--version ${KUBERAY_VERSION} \
	--kubeconfig /etc/rancher/k3s/k3s.yaml

kuberay-check:
	kubectl get pods -n kuberay-operator

raycluster:
	#Create Ray cluster
	#sh ray-cluster.sh
	#sudo kubectl apply -f k3s/ray-cluster.yaml
	kubectl apply -f https://raw.githubusercontent.com/data-max-hq/cost-effective-ml/main/k3s/ray-cluster.yaml

raycluster-check:
	kubectl get pods -n kubeflow-user-example-com

raycluster-port:
	kubectl port-forward svc/example-cluster-head-svc 8265:8265 -n kubeflow-user-example-com --address 0.0.0.0

uninstall:
	/usr/local/bin/k3s-uninstall.sh

uninstall-agent:
	/usr/local/bin/k3s-agent-uninstall.sh
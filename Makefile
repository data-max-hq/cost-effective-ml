datamax:
	 gcloud config configurations activate data-max

auth:
	gcloud auth login

git-clone:
	git clone git@github.com:data-max-hq/cost-efficient-ml.git

base-install:
	# Install requirements
	sudo apt-get update -y && sudo apt-get upgrade -y \
	&& curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh \
	&& sudo apt-get install apt-transport-https git make -y

	# install kustomize
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash \
	&& sudo mv kustomize /bin/

install-k3s:
	curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

install-k3s-node-token:
	sudo cat /var/lib/rancher/k3s/server/node-token

install-agent-k3s:
	SERVER_IP=192.168.11.120
	K3S_NODE_TOKEN=
	curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

k8s-dashboard:
	# https://docs.k3s.io/installation/kube-dashboard
	GITHUB_URL=https://github.com/kubernetes/dashboard/releases
	VERSION_KUBE_DASHBOARD=$(curl -w '%{url_effective}' -I -L -s -S ${GITHUB_URL}/latest -o /dev/null | sed -e 's|.*/||')
	sudo k3s kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/${VERSION_KUBE_DASHBOARD}/aio/deploy/recommended.yaml
	sudo k3s kubectl create -f dashboard.admin-user.yml -f dashboard.admin-user-role.yml
	sudo k3s kubectl -n kubernetes-dashboard create token admin-user
	sudo k3s kubectl port-forward svc/kubernetes-dashboard  -n kubernetes-dashboard 8443:443 --address='0.0.0.0'

install-kubeflow:
	git clone https://github.com/kubeflow/manifests.git
	cd manifests/
	while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

kubeflow-dashboard:
	sudo k3s kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

install-ray:
	sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
	sudo helm repo update
	# Install both CRDs and KubeRay operator v0.4.0.
	export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
	sudo helm install kuberay-operator kuberay/kuberay-operator --version 0.5.0 --kubeconfig /etc/rancher/k3s/k3s.yaml
	sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install raycluster kuberay/ray-cluster --version 0.5.0
	sudo k3s kubectl get pods

ray-dashboard:
	sudo k3s kubectl port-forward --address 0.0.0.0 svc/raycluster-kuberay-head-svc 8265:8265

install-helm:
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

install-gpu-req:
	sudo helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
	sudo helm repo update
	sudo helm upgrade -i nvdp nvdp/nvidia-device-plugin \
		--namespace nvidia-device-plugin \
		--set runtimeClassName=nvidia \
		--create-namespace \
		--version 0.14.0 \
		--kubeconfig /etc/rancher/k3s/k3s.yaml
#    sudo helm repo add nvgfd https://nvidia.github.io/gpu-feature-discovery
#	sudo helm repo update
#	sudo helm upgrade -i nvgfd nvgfd/gpu-feature-discovery \
#		--version 0.8.0 \
#		--namespace gpu-feature-discovery \
#		--set runtimeClassName=nvidia \
#		--set nfd.enableNodeFeatureApi=true \
#		--create-namespace \
#		--kubeconfig /etc/rancher/k3s/k3s.yaml

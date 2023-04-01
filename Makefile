datamax:
	 gcloud config configurations activate data-max

auth:
	gcloud auth login

git-clone:
	git clone git@github.com:data-max-hq/cost-efficient-ml.git

base-install:
	sudo apt-get update -y && sudo apt-get upgrade -y

	curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
	sudo apt-get update -y
	sudo apt-get install apt-transport-https git helm make -y
	# install customize
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
	sudo mv kustomize /bin/

install-k3s:
	curl -sfL https://get.k3s.io | sh -


install-agent-k3s:
	SERVER_IP=10.128.0.35
	K3S_NODE_TOKEN=
	curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=${K3S_NODE_TOKEN} sh -

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
	sudo k3kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:8080 --address='0.0.0.0'

install-ray:
	sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
	sudo helm repo update
	# Install both CRDs and KubeRay operator v0.4.0.
	export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
	sudo helm install kuberay-operator kuberay/kuberay-operator --version 0.4.0 --kubeconfig /etc/rancher/k3s/k3s.yaml
	sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install raycluster kuberay/ray-cluster --version 0.4.0
	sudo k3s kubectl get pods

ray-dashboard:
	sudo k3s kubectl port-forward --address 0.0.0.0 svc/raycluster-kuberay-head-svc 8265:8265



req:
	# Install requirements
	sudo apt-get update -y && sudo apt-get upgrade -y && \
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh && \
	sudo apt-get install apt-transport-https git make -y && \
	curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash && \
	sudo mv kustomize /bin/

nvidia-container-toolkit:
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

k3s:
	curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

k3sdashboard:
	chmod +x k3s-dashboard.sh
	./k3s-dashboard.sh

token:
	sudo k3s kubectl -n kubernetes-dashboard create token admin-user

k3sdashboard-port:
	sudo k3s kubectl port-forward svc/kubernetes-dashboard  -n kubernetes-dashboard 8443:443 --address='0.0.0.0'

gpu-operator:
	sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   	&& sudo helm repo update
	sudo helm upgrade --install --wait gpu-operator \
     --namespace gpu-operator \
     --create-namespace \
      nvidia/gpu-operator \
      --set driver.enabled=false \
      --set toolkit.enabled=false \
      --kubeconfig /etc/rancher/k3s/k3s.yaml

checkgpu:
	sudo kubectl get po -n gpu-operator

checknodes:
	sudo kubectl describe nodes

kubeflow:
	git clone https://github.com/data-max-hq/manifests.git
	cd manifests/
	while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

checkkubeflow:
	sudo kubectl get po -n kubeflow

kubeflow-port:
	sudo kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'


kuberay:
	sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
	sudo helm repo update
	sudo helm upgrade --install \
  	kuberay-operator kuberay/kuberay-operator \
  	--version 0.5.0 \
  	--kubeconfig /etc/rancher/k3s/k3s.yaml

checkkuberay:
	sudo k3s kubectl get pods

raycluster:
	#Install cluster
	sudo kubectl apply -f ray-cluster.yaml

checkraycluster:
	sudo k3s kubectl get pods -n kubeflow-user-example-com

raycluster-port:
	sudo k3s kubectl port-forward --address 0.0.0.0 svc/example-cluster-head-svc 8265:8265 -n kubeflow-user-example-com

uninstall:
	/usr/local/bin/k3s-uninstall.sh
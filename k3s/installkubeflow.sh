##install kubeflow
#git clone https://github.com/kubeflow/manifests.git
git clone https://github.com/data-max-hq/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sudo k3s kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

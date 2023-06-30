# Install Kubeflow
# git clone https://github.com/kubeflow/manifests.git
# enable unsecure
# https://github.com/kubeflow/manifests#change-default-user-password
# https://github.com/kubeflow/manifests/pull/2155
# https://github.com/kubeflow/manifests/issues/2225#issuecomment-1157931840
git clone https://github.com/data-max-hq/manifests.git
cd manifests/
while ! kustomize build example | awk '!/well-defined/' | sudo k3s kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

sudo k3s kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 --address='0.0.0.0'

# Change username password
# https://github.com/kubeflow/manifests#change-default-user-password

# delete kubeflow
kustomize build example | sudo k3s kubectl delete -f -
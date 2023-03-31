#!/bin/bash
sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/
sudo helm repo update
# Install both CRDs and KubeRay operator v0.4.0.
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo helm install kuberay-operator kuberay/kuberay-operator --version 0.4.0 --kubeconfig /etc/rancher/k3s/k3s.yaml

# Check the KubeRay operator Pod in `default` namespace
sudo k3s kubectl get pods
# NAME                                READY   STATUS    RESTARTS   AGE
# kuberay-operator-6fcbb94f64-mbfnr   1/1     Running   0          17s

sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install raycluster kuberay/ray-cluster --version 0.4.0

sudo k3s kubectl get pods

sudo k3s kubectl port-forward --address 0.0.0.0 svc/raycluster-kuberay-head-svc 8265:8265

sudo k3s kubectl exec -it ${RAYCLUSTER_HEAD_POD} -- bash
python -c "import ray; ray.init(); print(ray.cluster_resources())" # (in Ray head Pod)
#!/bin/bash
sudo helm repo add kuberay https://ray-project.github.io/kuberay-helm/

# Install both CRDs and KubeRay operator v0.4.0.
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo helm install kuberay-operator kuberay/kuberay-operator --version 0.4.0 --kubeconfig /etc/rancher/k3s/k3s.yaml

# Check the KubeRay operator Pod in `default` namespace
sudo k3s kubectl get pods
# NAME                                READY   STATUS    RESTARTS   AGE
# kuberay-operator-6fcbb94f64-mbfnr   1/1     Running   0          17s

sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install raycluster kuberay/ray-cluster --version 0.4.0

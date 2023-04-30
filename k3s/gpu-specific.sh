
#distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
#      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
#      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
#            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
#            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

#sudo apt-get update \
#    && sudo apt-get install -y nvidia-container-toolkit-base


#sudo helm install --wait --generate-name \
#     -n gpu-operator --create-namespace \
#     nvidia/gpu-operator \
#    --set toolkit.env[0].name=CONTAINERD_CONFIG \
#    --set toolkit.env[0].value=/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl \
#    --set toolkit.env[1].name=CONTAINERD_SOCKET \
#    --set toolkit.env[1].value=/run/k3s/containerd/containerd.sock \
#    --set toolkit.env[2].name=CONTAINERD_RUNTIME_CLASS \
#    --set toolkit.env[2].value=nvidia \
#    --set toolkit.env[3].name=CONTAINERD_SET_AS_DEFAULT \
#    --set-string toolkit.env[3].value=true \
#      --kubeconfig /etc/rancher/k3s/k3s.yaml

sudo helm repo add nvidia https://helm.ngc.nvidia.com/nvidia \
   && sudo helm repo update

sudo helm install --generate-name --namespace gpu-operator --create-namespace \
  nvidia/gpu-operator \
    --set toolkit.env[0].name=CONTAINERD_CONFIG \
    --set toolkit.env[0].value=/var/lib/rancher/k3s/agent/etc/containerd/config.toml.tmpl \
    --set toolkit.env[1].name=CONTAINERD_SOCKET \
    --set toolkit.env[1].value=/run/k3s/containerd/containerd.sock \
    --set toolkit.env[2].name=CONTAINERD_RUNTIME_CLASS \
    --set toolkit.env[2].value=nvidia \
    --set toolkit.env[3].name=CONTAINERD_SET_AS_DEFAULT \
    --set-string toolkit.env[3].value=true \
    --kubeconfig /etc/rancher/k3s/k3s.yaml


sudo helm list -n gpu-operator --kubeconfig /etc/rancher/k3s/k3s.yaml

sudo helm uninstall gpu-operator-1682794010 -n gpu-operator --kubeconfig /etc/rancher/k3s/k3s.yaml
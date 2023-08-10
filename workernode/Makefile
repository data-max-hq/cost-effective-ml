.PHONY: nvidia-container-toolkit check-toolkit k3s-agents uninstall-agent

nvidia-container-toolkit:
	distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
    && sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

k3s-agents:
	#SERVER_IP=192.168.8.27
	#K3S_NODE_TOKEN=
	curl -sfL https://get.k3s.io | K3S_URL=https://${SERVER_IP}:6443 K3S_TOKEN=12345 INSTALL_K3S_VERSION=v1.25.8+k3s1 sh -

uninstall-agent:
	/usr/local/bin/k3s-agent-uninstall.sh
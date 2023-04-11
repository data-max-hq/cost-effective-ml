# Cost Effective ML
Building a Hybrid Kubernetes Cluster for Scalable and Cost-Effective ML Training with Ray and Kubeflow

## Building the hybrid Kubernetes Cluster
![1-setup.png](diagrams/images/1-setup.png)

## ToDo:
1. Create two nodes and add them in cluster
2. Enable dashboard
3. Add nodes in separate node groups
4. Install kubeflow pipelines
5. Run sample tasks in separate node groups (taints and tolerations)
6. Install Ray and run ray tasks from Kubeflow
7. Enable Ray dashboard
8. Do the same with GPU nodes

## Prerequisites
These tools must be installed in the nodes before starting:
* Git
* Helm3
* Kustomize

## Troubleshooting
* Configure private registries in k3s: https://docs.k3s.io/installation/private-registry
  * https://breadnet.co.uk/using-google-artifact-registry-with-k3s/
* Restart k3s and k3s-agent: https://docs.k3s.io/upgrades/manual#restarting-k3s


## Links 
* https://cloud.google.com/blog/products/ai-machine-learning/build-a-ml-platform-with-kubeflow-and-ray-on-gke
* https://github.com/ray-project/kuberay
* https://docs.ray.io/en/latest/cluster/kubernetes/examples/gpu-training-example.html#kuberay-gpu-training-example
* https://ray-project.github.io/kuberay/deploy/helm/


Made with ❤️ by [Data-Max.io](https://www.data-max.io/).
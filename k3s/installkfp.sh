# sudo apt-get install git -y

# https://www.kubeflow.org/docs/components/pipelines/v1/installation/standalone-deployment/
# https://www.kubeflow.org/docs/components/pipelines/v2/installation/quickstart/
export PIPELINE_VERSION=1.8.20
sudo k3s kubectl create ns kubeflow
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"
sudo k3s kubectl wait --for condition=established --timeout=60s crd/applications.app.k8s.io
sudo k3s kubectl apply -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"

# delete
export PIPELINE_VERSION=1.8.20
sudo k3s kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/env/dev?ref=$PIPELINE_VERSION"
sudo k3s kubectl delete -k "github.com/kubeflow/pipelines/manifests/kustomize/cluster-scoped-resources?ref=$PIPELINE_VERSION"

#
sudo k3s kubectl port-forward svc/ml-pipeline-ui  -n kubeflow 8080:80 --address='0.0.0.0'
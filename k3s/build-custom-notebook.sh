cd components/example-notebook-servers/jupyter

make docker-build

gcloud auth configure-docker us-central1-docker.pkg.dev

docker tag docker tag kubeflownotebookswg/jupyter:v1.5.0-rc.0-299-g916bd0e5-dirty us-central1-docker.pkg.dev/sustained-drake-368613/cost-efficient-ml/notebook:3.7.10

docker push us-central1-docker.pkg.dev/sustained-drake-368613/cost-efficient-ml/notebook:3.7.10
#!/bin/bash

gcloud builds submit --config=cloudbuild-rayserver-gpu.yaml \
  --substitutions=_LOCATION="us-central1",_REPOSITORY="cost-efficient-ml",_IMAGE="ray-server-ml",_TAG="2.3.0-py38-gpu" \
  .
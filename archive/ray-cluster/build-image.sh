#!/bin/bash

gcloud builds submit --config=cloudbuild-rayserver.yaml \
  --substitutions=_LOCATION="us-central1",_REPOSITORY="cost-efficient-ml",_IMAGE="ray-server",_TAG="2.3.0-py38-10" \
  .
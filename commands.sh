# Create nodes GCP
gcloud compute instances create k8s-demo-node \
 --project=sustained-drake-368613 \
 --zone=europe-west3-c \
 --machine-type=e2-medium \
 --network-interface=network-tier=PREMIUM,subnet=default \
 --maintenance-policy=MIGRATE \
 --provisioning-model=STANDARD \
 --service-account=876770287571-compute@developer.gserviceaccount.com \
 --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
 --create-disk=auto-delete=yes,boot=yes,device-name=k8s-demo-node,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230125,mode=rw,size=10,type=projects/sustained-drake-368613/zones/europe-west3-c/diskTypes/pd-ssd \
 --no-shielded-secure-boot \
 --shielded-vtpm \
 --shielded-integrity-monitoring \
 --labels=owner=sadik \
 --reservation-affinity=any


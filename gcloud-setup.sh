#!/bin/bash -ex

## default for testing to a teeny tiny cluster to avoid burning up
## compute credits

NUM_NODES=3
INSTANCE_TYPE=n1-standard-1
NAMESPACE=gcloud-test
CLUSTER_NAME=test-cluster-a
CHARTNAME=jhub-1
ZONE=us-central1-f

project=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
zone=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)
repo=$( curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq -r '.repo')


## uncomment below to override above settings if you want a larger cluster

# NUM_NODES=3
# INSTANCE_TYPE=n1-standard-1
# NAMESPACE=gcloud-test
# CLUSTER_NAME=test-cluster-1
# CHARTNAME=jhub
# ZONE=us-central1-f

## Assume you are starting from Google Cloud Shel (GCS)
##   https://cloud.google.com/shell/

rm -rf ~/zero-to-jupyterhub
cd $HOME
git clone https://github.com/aculich/zero-to-jupyterhub/

cd $HOME/zero-to-jupyterhub
cat > gcloud-config.sh <<EOF
NUM_NODES=${NUM_NODES}
INSTANCE_TYPE=${INSTANCE_TYPE}
NAMESPACE=${NAMESPACE}
CLUSTER_NAME=${CLUSTER_NAME}
CHARTNAME=${CHARTNAME}
ZONE=${ZONE}
EOF
cat gcloud-config.sh
. gcloud-config.sh

hubCookieSecret=$(openssl rand -hex 32)
tokenProxy=$(openssl rand -hex 32)
cat >config.yaml <<EOF
hub:
   # output of first execution of 'openssl rand -hex 32'
   cookieSecret: "${hubCookieSecret}"
token:
    # output of second execution of 'openssl rand -hex 32'
    proxy: "${tokenProxy}"
singleuser:
  image:
    name: gcr.io/${project}/default-image
    tag: latest
storage:
  type: none
EOF
cat config.yaml

git clone https://github.com/aculich/s2i-builders
cd $HOME/zero-to-jupyterhub/s2i-builders/singleuser-builder
make
s2i build ${repo} aculich/singleuser-builder:$(cat version) gcr.io/${project}/default-image:latest
gcloud docker -- push gcr.io/${project}/default-image:latest

cd $HOME/zero-to-jupyterhub
## logins are not required when running on gcp instances
#gcloud auth login
#gcloud auth application-default login

time gcloud container clusters create ${CLUSTER_NAME} --project ${project} --num-nodes=${NUM_NODES} --zone=${ZONE}


sudo chown -R $USER $HOME/.config || echo "ignoring chown error"
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
echo "Run this in another tab while helm install is --wait'ing"
echo "kubectl --namespace=${NAMESPACE} get pod; kubectl --namespace=${NAMESPACE} get svc"
helm init
sleep 20
JUPYTER_CHART=https://github.com/jupyterhub/helm-chart/releases/download/v0.1/jupyterhub-0.1.tgz
helm install --wait --timeout=900 ${JUPYTER_CHART} --name=${CHARTNAME} --namespace=${NAMESPACE} -f config.yaml

# helm upgrade ${CHARTNAME} ${JUPYTER_CHART} -f config.yaml

# gcloud container clusters get-credentials binder-cluster-dev --zone=us-central1-a


#!/usr/bin/env bash -ex

. gcloud-config.sh

## Assume you are starting from Google Cloud Shel (GCS)
##   https://cloud.google.com/shell/

sudo gcloud components install kubectl
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
git clone https://github.com/data-8/jupyterhub-k8s
cd jupyterhub-k8s
hubCookieSecret=$(openssl rand -hex 32)
tokenProxy=$(openssl rand -hex 32)
cat >config.yaml <<EOF
hub:
   # output of first execution of 'openssl rand -hex 32'
   cookieSecret: "${hubCookieSecret}"
token:
    # output of second execution of 'openssl rand -hex 32'
    proxy: "${tokenProxy}"
EOF
cat config.yaml
#gcloud auth login
gcloud auth application-default login
gcloud config set project ${DEVSHELL_PROJECT_ID}
gcloud config get-value project
gcloud container clusters create ${CLUSTER_NAME} --num-nodes=${NUM_NODES} --zone=${ZONE}
helm init
helm install helm-chart --name=${CHARTNAME} --namespace=${NAMESPACE} -f config.yaml
kubectl --namespace=${NAMESPACE} get pod
kubectl --namespace=${NAMESPACE} get svc

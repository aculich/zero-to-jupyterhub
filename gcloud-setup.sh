#!/usr/bin/env bash -ex

## default for testing to a teeny tiny cluster to avoid burning up
## compute credits

NUM_NODES=1
INSTANCE_TYPE=n1-standard-1
NAMESPACE=gcloud-test
CLUSTER_NAME=test-cluster-a
CHARTNAME=jhub-1
ZONE=us-central1-f


## uncomment below to override above settings if you want a larger cluster

# NUM_NODES=3
# INSTANCE_TYPE=n1-standard-1
# NAMESPACE=gcloud-test
# CLUSTER_NAME=test-cluster-1
# CHARTNAME=jhub
# ZONE=us-central1-f

## Assume you are starting from Google Cloud Shel (GCS)
##   https://cloud.google.com/shell/

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
cd $HOME
sudo gcloud components update --version=149.0.0
sudo gcloud components install kubectl
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
git clone https://github.com/data-8/jupyterhub-k8s
cd $HOME/jupyterhub-k8s
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
gcloud auth login
gcloud auth application-default login
gcloud config set project ${DEVSHELL_PROJECT_ID}
gcloud config get-value project
time gcloud container clusters create ${CLUSTER_NAME} --num-nodes=${NUM_NODES} --zone=${ZONE}
echo "Sleeping for 3 seconds to let things settle..."
sleep 3
# FIXME: https://github.com/kubernetes/helm/issues/2114
# FIXME: pull request needs to be merged before this will work
# FIXME: may be moot if helm install --wait is all that's needed
# helm init --wait
helm init
# FIXME: https://github.com/kubernetes/helm/issues/1805
# FIXME: have not yet tested whether --wait works with helm install
helm install --wait helm-chart --name=${CHARTNAME} --namespace=${NAMESPACE} -f config.yaml
kubectl --namespace=${NAMESPACE} get pod
kubectl --namespace=${NAMESPACE} get svc

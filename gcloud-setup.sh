#!/bin/bash -ex

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

rm -rf ~/zero-to-jupyterhub ~/jupyterhub-k8s
cd $HOME
git clone https://github.com/aculich/zero-to-jupyterhub/
git clone https://github.com/data-8/jupyterhub-k8s/
cd $HOME/zero-to-jupyterhub
cat > gcloud-config.sh <<EOF
NUM_NODES=${NUM_NODES}
INSTANCE_TYPE=${INSTANCE_TYPE}
NAMESPACE=${NAMESPACE}
CLUSTER_NAME=${CLUSTER_NAME}
CHARTNAME=${CHARTNAME}
ZONE=${ZONE}
EOF
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
sudo gcloud components update --version=149.0.0
sudo gcloud components install kubectl
gcloud auth login
gcloud auth application-default login
gcloud config set project ${DEVSHELL_PROJECT_ID}
gcloud config get-value project
gcloud config set compute/zone ${ZONE}
gcloud config get-value compute/zone
time gcloud container clusters create ${CLUSTER_NAME} --num-nodes=${NUM_NODES}
#sudo chown -R $USER $HOME/.config
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
echo "Run this in another tab while helm install is --wait'ing"
echo "kubectl --namespace=${NAMESPACE} get pod; kubectl --namespace=${NAMESPACE} get svc" 
helm init
cd $HOME/jupyterhub-k8s
JUPYTER_CHART=https://github.com/jupyterhub/helm-chart/releases/download/v0.1/jupyterhub-0.1.tgz
helm install ${JUPYTER_CHART} --name=${CHARTNAME} --namespace=${NAMESPACE} -f conf
ig.yaml

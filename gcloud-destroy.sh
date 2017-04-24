#!/usr/bin/env bash -ex

## Assume you are starting from Google Cloud Shell (GCS)
##   https://cloud.google.com/shell/

## since scripts in this repo are just for testing purposes, NOT FOR
## ACTUAL PRODUCTION DEPLOYMENTS, we don't bother nicely prompting to
## go ahead... we just immediately DESTROY everything so we can
## quickly rinse & repeat setting up and tearing down clusters
echo "deleting cluster..."
#time gcloud --quiet container clusters delete ${CLUSTER_NAME}
time gcloud --quiet container clusters delete test-cluster-a --zone us-central1-f
echo "deleting controller..."
time gcloud --quiet compute instances delete jhub-controller --zone us-central1-f

## FIXME: currently everything is hard-coded for simplicity, but if course this
## needs to be fixed later once setup process has stabilized.

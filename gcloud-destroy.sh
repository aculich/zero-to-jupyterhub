#!/usr/bin/env bash -ex

. $HOME/zero-to-jupyterhub/gcloud-config.sh

## Assume you are starting from Google Cloud Shel (GCS)
##   https://cloud.google.com/shell/

## since scripts in this repo are just for testing purposes, NOT FOR
## ACTUAL PRODUCTION DEPLOYMENTS, we don't bother nicely prompting to
## go ahead... we just immediately DESTROY everything so we can
## quickly rinse & repeat setting up and tearing down clusters
time gcloud --quiet container clusters delete test-cluster-1 --zone=us-central1-b
cd $HOME
rm -rf $HOME/jupyterhub-k8s
rm -rf $HOME/zero-to-jupyterhub

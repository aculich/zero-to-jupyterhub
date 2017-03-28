#!/usr/bin/env bash -ex

. gcloud-config.sh

## Assume you are starting from Google Cloud Shel (GCS)
##   https://cloud.google.com/shell/

time gcloud container clusters delete test-cluster-1 --zone=us-central1-b

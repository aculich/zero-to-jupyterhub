#!/usr/bin/env bash -ex

## default for testing to a teeny tiny cluster to avoid burning up
## compute credits

NUM_NODES=1
INSTANCE_TYPE=g1-small
NAMESPACE=gcloud-test
CLUSTER_NAME=test-cluster-1
CHARTNAME=jhub
ZONE=us-central1-b


## uncomment below to override above settings if you want a larger cluster

# NUM_NODES=3
# INSTANCE_TYPE=n1-standard-1
# NAMESPACE=gcloud-test
# CLUSTER_NAME=test-cluster-1
# CHARTNAME=jhub
# ZONE=us-central1-b

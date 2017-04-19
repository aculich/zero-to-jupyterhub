#!/bin/bash

set -e

PROGNAME=$(basename $0)

export CLOUDSDK_CORE_DISABLE_PROMPTS=1
apt-get purge --yes google-cloud-sdk kubectl

#!/bin/bash

set -e

PROGNAME=$(basename $0)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION ...] [project]
Bootstrap on Google Cloud Platform (GCP).

On Google Cloud Shell you can invoke as:

  ${PROGNAME} \$DEVSHELL_PROJECT_ID

Options:
-h, --help          display this usage message and exit
EOF

    exit 1
}

project="${DEVSHELL_PROJECT_ID}"
while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    -*)
        usage "Unknown option '$1'"
        ;;
    *)
        if [ -z "$project" ] ; then
            project="$1"
        else
            usage "Too many arguments"
        fi
        ;;
    esac
    shift
done

if [ -z "$project" ] ; then
    usage "Not enough arguments"
fi

cat <<EOF
project=${project}
EOF

set -x

gcloud compute --project "${project}" instances create "jhub-controller" --zone "us-central1-f" --machine-type "g1-small" --subnet "default" --maintenance-policy "MIGRATE" --service-account "1048240305778-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/cloud-platform" --tags "http-server","https-server" --image "ubuntu-1610-yakkety-v20170330" --image-project "ubuntu-os-cloud" --boot-disk-size "20" --boot-disk-type "pd-ssd" --boot-disk-device-name "jhub-controller"

# gcloud compute --project "${project}" instances create "jhub-controller" --zone "us-central1-f" --machine-type "g1-small" --subnet "default" --metadata "startup-script=https://raw.githubusercontent.com/yuvipanda/binder-deployment/master/setup.bash" --maintenance-policy "MIGRATE" --service-account "1048240305778-compute@developer.gserviceaccount.com" --scopes "https://www.googleapis.com/auth/cloud-platform" --tags "http-server","https-server" --image "ubuntu-1610-yakkety-v20170330" --image-project "ubuntu-os-cloud" --boot-disk-size "20" --boot-disk-type "pd-ssd" --boot-disk-device-name "jhub-controller"

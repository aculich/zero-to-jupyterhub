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
Usage: $PROGNAME [OPTION ...] [project] [repo]
Bootstrap on Google Cloud Platform (GCP).

On Google Cloud Shell you can invoke as:

  ${PROGNAME} \$DEVSHELL_PROJECT_ID

Options:
-h, --help          display this usage message and exit
EOF

    exit 1
}

project="${DEVSHELL_PROJECT_ID}"
repo="${REPO}"
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
        elif [ -z "$repo" ] ; then
            repo="$1"
        else
            usage "Too many arguments"
        fi
        ;;
    esac
    shift
done

if [ -z "$repo" ] ; then
    usage "Not enough arguments"
fi

cat <<EOF
project=${project}
repo=${repo}
EOF

set -x
# project_number=$(curl "http://metadata.google.internal/computeMetadata/v1/project/numeric-project-id" -H "Metadata-Flavor: Google")
project_number=$(gcloud projects describe $DEVSHELL_PROJECT_ID --format json | jq -r '.projectNumber')
service_account="${project_number}-compute@developer.gserviceaccount.com"
startup_script="https://raw.githubusercontent.com/aculich/zero-to-jupyterhub/master/gcloud-controller-setup.sh"

gcloud compute --project "${project}" instances create "jhub-controller" --zone "us-central1-f" --machine-type "g1-small" --subnet "default" --metadata "project=${project},repo=${repo},startup-script-url=${startup_script}" --maintenance-policy "MIGRATE" --service-account "${service_account}" --scopes "https://www.googleapis.com/auth/cloud-platform" --tags "bootstrapped" --image "ubuntu-1610-yakkety-v20170330" --image-project "ubuntu-os-cloud" --boot-disk-size "20" --boot-disk-type "pd-ssd" --boot-disk-device-name "jhub-controller"

echo "Waiting 20 seconds for system to boot and begin logging..."
sleep 20
gcloud compute --project "${project}" ssh --zone "${zone}" "ubuntu@jhub-controller" --command "sudo tail -f /var/log/syslog"

#!/bin/bash

set -e

PROGNAME=$(basename $0)

## latest versions as of 2017-03-24
# $ apt-cache madison docker-engine
##  docker-engine | 17.03.0~ce-0~ubuntu-trusty | https://apt.dockerproject.org/repo/ ubuntu-trusty/main amd64 Packages
##  docker-engine | 1.13.1-0~ubuntu-trusty     | https://apt.dockerproject.org/repo/ ubuntu-trusty/main amd64 Packages
##  docker-engine | 1.13.0-0~ubuntu-trusty     | https://apt.dockerproject.org/repo/ ubuntu-trusty/main amd64 Packages
##    ...

DOCKER_VERSION=17.03.0~ce-0

export CLOUDSDK_CORE_DISABLE_PROMPTS=1

# Create an environment variable for the correct distribution
export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"

# Add the Cloud SDK distribution URI as a package source
echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud Platform public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install --yes google-cloud-sdk=140.0.0-0ubuntu1~16.10 kubectl jq
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | sudo bash
wget --directory-prefix=/tmp https://github.com/openshift/source-to-image/releases/download/v1.1.5/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz
(cd /usr/local/bin && tar --no-overwrite-dir -zxvf /tmp/source-to-image-v1.1.5-4dd7721-linux-amd64.tar.gz)


## Recommended extra packages for Trusty 14.04¶
##    Unless you have a strong reason not to, install the linux-image-extra-*
##    packages, which allow Docker to use the aufs storage drivers.
# apt-get install -y --no-install-recommends \
#     linux-image-extra-$(uname -r) \
#     linux-image-extra-virtual

## Set up the repository
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    make \
    wget \
    uuid

curl -fsSL https://apt.dockerproject.org/gpg | apt-key add -
apt-key fingerprint 58118E89F3A912897C070ADBF76221572C52609D
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -c -s) \
       main"

apt-get update

VERSION=${DOCKER_VERSION}~ubuntu-$(lsb_release -c -s)
apt-get -y install docker-engine=$VERSION

## Wrapper script to avoid explicitly requiring sudo to use docker (since
## examples for Docker on Mac and Docker on Windows do not require it).

# cat > /usr/local/bin/docker <<EOF
# #!/bin/bash
#
# sudo /usr/bin/docker $*
# EOF
# chmod 755 /usr/local/bin/docker

## add default Jetstream user (uid:1000) to docker group so the user does not
## have to type `sudo docker` each time.
## https://www.explainxkcd.com/wiki/index.php/149:_Sandwich
DEFAULT_USER=$(getent passwd 1000 | cut -d: -f1)
#SECONDARY_USER=$(getent passwd 1001 | cut -d: -f1)
adduser $DEFAULT_USER docker
#adduser $SECONDARY_USER docker

## automatically install and enable byobu for the default user
apt-get -y install byobu
sudo -u $DEFAULT_USER -i /usr/bin/byobu-launcher-install
#sudo -u $SECONDARY_USER -i /usr/bin/byobu-launcher-install

project=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")
zone=$(curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | cut -d/ -f4)
repo=$( curl --silent "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true" -H "Metadata-Flavor: Google" | jq -r '.repo')

curl --silent "https://raw.githubusercontent.com/aculich/zero-to-jupyterhub/master/gcloud-setup.sh?$(uuid)" | sudo -u $DEFAULT_USER -i bash

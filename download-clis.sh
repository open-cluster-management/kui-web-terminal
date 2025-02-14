#!/bin/bash

# Copyright (c) 2020 Red Hat, Inc.
# Copyright Contributors to the Open Cluster Management project

# Licensed Materials - Property of IBM
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights -
# Use, duplication or disclosure restricted by GSA ADP
# IBM Corporation - initial API and implementation

set -e


ARCH=$(uname -m | sed 's/x86_64/amd64/g')

DOCKER_REGISTRY=hyc-cloud-private-integration-docker-local.artifactory.swg-devops.com
DOCKER_NAMESPACE=ibmcom

# Create downloads directory for CLI binaries
mkdir -p ./downloads

if [ "$ARCH" = "amd64" ]; then
  echo "Downloading oc & kubectl ..."
  curl -fksSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest-4.8/openshift-client-linux.tar.gz | tar -xvz -C ./downloads/ oc kubectl
  [[ ! -f "downloads/oc" ]] && echo "download oc failed" && exit -1
  mv ./downloads/oc ./downloads/oc-linux-amd64
  [[ ! -f "downloads/kubectl" ]] && echo "download kubectl failed" && exit -1
  mv ./downloads/kubectl ./downloads/kubectl-linux-amd64
  echo "Downloaded openshift origin to downloads/"

  echo "Downloading helm v3.3.z..."
  curl -fksSL https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/helm/latest/helm-linux-amd64 -o ./downloads/helm-linux-amd64
  [[ ! -f "downloads/helm-linux-amd64" ]] && echo "download helm failed" && exit -1
  echo "Downloaded helm v3 to downloads/"

  echo "Downloading subctl v0.9.0"
  assetURL=$(curl -Ls -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/submariner-io/submariner-operator/releases | jq -r '.[] | select(.tag_name=="v0.9.0") | .assets[] | select(.name|contains("linux-amd64")) | .browser_download_url')
  # echo " assetURL is $assetURL"
  curl -fksSL $assetURL | tar -xvJ -C ./downloads/ subctl-release-0.9-198fe39/subctl-release-0.9-198fe39-linux-amd64
    [[ ! -f "downloads/subctl-release-0.9-198fe39/subctl-release-0.9-198fe39-linux-amd64" ]] && echo "download subctl failed" && exit -1
  mv ./downloads/subctl-release-0.9-198fe39/subctl-release-0.9-198fe39-linux-amd64 ./downloads/subctl-linux-amd64
  rmdir ./downloads/subctl-release-0.9-198fe39
  echo "Downloaded subctl v0.9.0 to downloads/"
  
fi

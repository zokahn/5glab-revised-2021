#!/bin/bash
_CMD=openshift-baremetal-install
_PULLSECRETFILE=~/pull-secret.txt
_DIR=/home/kni/
_VERSION=stable-4.10
_URL="https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${_VERSION}"

_RELEASE_IMAGE=$(curl -s ${_URL}/release.txt | grep 'Pull From: quay.io' | awk -F ' ' '{print $3}')

curl -s ${_URL}/openshift-client-linux.tar.gz | tar zxvf - oc kubectl
sudo mv -f oc /usr/local/bin
sudo mv -f kubectl /usr/local/bin
oc adm release extract \
  --registry-config "${_PULLSECRETFILE}" \
  --command=${_CMD} \
  --to "${_DIR}" ${_RELEASE_IMAGE}

sudo mv -f openshift-baremetal-install /usr/local/bin

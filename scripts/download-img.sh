#!/bin/bash -x

DEST_DIR="/home/kni/rhcos_image_cache"
CLI_TOOLSDIR="/usr/local/bin"
HTTP_PORT=8080

#### make sure podman is installed and active, pull the image

yum -y install podman
systemctl enable podman --now
podman pull registry.centos.org/centos/httpd-24-centos7:latest


#### create the image cache dir and set the right selinux contexts
mkdir ${DEST_DIR}
semanage fcontext -a -t httpd_sys_content_t "${DEST_DIR}(/.*)?"
restorecon -Rv ${DEST_DIR}/


#### Download the images to the image cache

#commit ID
export COMMIT_ID=$(${CLI_TOOLSDIR}/openshift-baremetal-install version | grep '^built from commit' | awk '{print $4}')

#image that will land on the nodes
export RHCOS_OPENSTACK_URI=$(curl -s -S https://raw.githubusercontent.com/openshift/installer/$COMMIT_ID/data/data/rhcos.json  | jq .images.openstack.path | sed 's/"//g')

#bootstrap vm
export RHCOS_QEMU_URI=$(curl -s -S https://raw.githubusercontent.com/openshift/installer/$COMMIT_ID/data/data/rhcos.json  | jq .images.qemu.path | sed 's/"//g')

#get path where images are published
export RHCOS_PATH=$(curl -s -S https://raw.githubusercontent.com/openshift/installer/$COMMIT_ID/data/data/rhcos.json | jq .baseURI | sed 's/"//g')

#sha bootstrap
export RHCOS_QEMU_SHA_UNCOMPRESSED=$(curl -s -S https://raw.githubusercontent.com/openshift/installer/$COMMIT_ID/data/data/rhcos.json  | jq -r '.images.qemu["uncompressed-sha256"]')

#sha rhcos
export RHCOS_OPENSTACK_SHA_COMPRESSED=$(curl -s -S https://raw.githubusercontent.com/openshift/installer/$COMMIT_ID/data/data/rhcos.json  | jq -r '.images.openstack.sha256')

curl -L ${RHCOS_PATH}${RHCOS_QEMU_URI} -o ${DEST_DIR}/${RHCOS_QEMU_URI}
curl -L ${RHCOS_PATH}${RHCOS_OPENSTACK_URI} -o ${DEST_DIR}/${RHCOS_OPENSTACK_URI}


#### Create the container to serve out the images on port 8080

podman stop rhcos_image_cache

podman run -d --name rhcos_image_cache --rm \
  -v ${DEST_DIR}:/var/www/html \
  -p ${HTTP_PORT}:8080/tcp \
  registry.centos.org/centos/httpd-24-centos7:latest


### echo the needed lines to install-config.yaml
export BAREMETAL_IP=$(ip addr show dev baremetal | awk '/inet /{print $2}' | cut -d"/" -f1)
#echo 'Add this to the install config under the baremetal: section '

echo "    bootstrapOSImage: http://${BAREMETAL_IP}:${HTTP_PORT}/${RHCOS_QEMU_URI}?sha256=${RHCOS_QEMU_SHA_UNCOMPRESSED}"
echo "    clusterOSImage: http://${BAREMETAL_IP}:${HTTP_PORT}/${RHCOS_OPENSTACK_URI}?sha256=${RHCOS_OPENSTACK_SHA_COMPRESSED}"

#!/bin/bash
VIRT_DIR=/var/lib/libvirt/images

VIRT_DOMAIN='simpletest.nl'


nodes="master0 master1 master2"
NUM=1
for node in $nodes; do
    echo "Kicking $node into gear"
    virsh destroy $node
    virsh undefine $node
    virt-install --name=$node --ram=16384 --vcpus=4 \
                --disk path=$VIRT_DIR/$node.dsk,size=70,bus=virtio \
                --pxe --noautoconsole --graphics=vnc --hvm \
                --network bridge=br1_100,model=virtio,mac=52:54:00:"$NUM"5:bd:2f \
                --network bridge=br2_110,model=virtio,mac=52:54:00:"$NUM"5:cd:2f \
                --os-variant=rhel8.2 --boot network,hd
    NUM=$((NUM+1))
done

nodes="worker0 worker1 worker2"
NUM=4
for node in $nodes; do
    echo "Kicking $node into gear"
    virsh destroy $node
    virsh undefine $node
    virt-install --name=$node --ram=32768 --vcpus=4 \
                --disk path=$VIRT_DIR/$node.dsk,size=70,bus=virtio \
                --pxe --noautoconsole --graphics=vnc --hvm \
                --network bridge=br1_100,model=virtio,mac=52:54:00:"$NUM"5:bd:2f \
                --network bridge=br2_110,model=virtio,mac=52:54:00:"$NUM"5:cd:2f \
                --os-variant=rhel8.2 --boot network,hd
    NUM=$((NUM+1))
done

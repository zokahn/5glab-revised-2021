NODE_NAME=tooling
IMAGES_DIR=/var/lib/libvirt/images
VIRT_DIR=/var/lib/libvirt/images
OFFICIAL_IMAGE=rhel-8.4-x86_64-kvm.qcow2
PASSWORD_FOR_VMS='r3dh4t1!'

virsh destroy $NODE_NAME  > /dev/null 2>&1
virsh undefine $NODE_NAME > /dev/null 2>&1
rm -f ${VIRT_DIR}/$NODE_NAME.qcow2 > /dev/null 2>&1


cd $VIRT_DIR
qemu-img create -f qcow2 $NODE_NAME.qcow2 50G
virt-resize --expand /dev/sda3 /$IMAGES_DIR/$OFFICIAL_IMAGE $NODE_NAME.qcow2

cat > /tmp/ifcfg-eth1 << EOF
#VLAN100
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
MTU=1500
BRIDGE=provisioning
EOF

cat > /tmp/ifcfg-eth0 << EOF
#VLAN110
DEVICE=eth1
BOOTPROTO=none
ONBOOT=yes
MTU=1500
BRIDGE=baremetal
EOF


cat > /tmp/ifcfg-baremetal << EOF
DEVICE=baremetal
TYPE=Bridge
IPADDR=10.0.11.28
NETMASK=255.255.255.224
GATEWAY=10.0.11.30
DNS1=1.1.1.1
DNS2=8.8.8.8
ONBOOT=yes
MTU=1500
BOOTPROTO=static
DELAY=0
EOF

cat > /tmp/ifcfg-provisioning << EOF
DEVICE=provisioning
TYPE=Bridge
IPADDR=10.0.10.28
NETMASK=255.255.255.224
ONBOOT=yes
MTU=1500
BOOTPROTO=static
DELAY=0
EOF

virt-customize -a $NODE_NAME.qcow2 \
  --hostname $NODE_NAME \
  --root-password password:r3dh4t1! \
  --uninstall cloud-init \
  --copy-in /tmp/ifcfg-eth0:/etc/sysconfig/network-scripts/ \
  --copy-in /tmp/ifcfg-eth1:/etc/sysconfig/network-scripts/ \
  --copy-in /tmp/ifcfg-baremetal:/etc/sysconfig/network-scripts/ \
  --copy-in /tmp/ifcfg-provisioning:/etc/sysconfig/network-scripts/ \
  --timezone Europe/Amsterdam \
  --selinux-relabel

virt-install --ram 16384 --vcpus 2 --os-variant rhel8.1\
  --disk path=$VIRT_DIR/$NODE_NAME.qcow2,device=disk,bus=virtio,format=qcow2 \
  --import \
  --network bridge=br1_100,model=virtio --name $NODE_NAME \
  --network bridge=br2_110,model=virtio \
  --cpu host-passthrough,cache.mode=passthrough \
  --graphics vnc,listen=0.0.0.0 --noautoconsole \
  --dry-run --print-xml > /tmp/$NODE_NAME.xml

virsh define --file /tmp/$NODE_NAME.xml
virsh start $NODE_NAME

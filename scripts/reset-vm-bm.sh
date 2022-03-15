#!/bin/bash

for i in $(sudo virsh list | tail -n +3 | grep bootstrap | awk {'print $2'});
do
  sudo virsh destroy $i;
  sudo virsh undefine $i;
  sudo virsh vol-delete $i --pool $i;
  sudo virsh vol-delete $i.ign --pool $i;
  sudo virsh pool-destroy $i;
  sudo virsh pool-undefine $i;
done

rm -rf /home/kni/manifests
mkdir -p /home/kni/manifests

cp /home/kni/install-config.yaml /home/kni/manifests/
sudo rm -rf /var/lib/libvirt/openshift-images/*

ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6230 power off
ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6231 power off
ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6232 power off
ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6233 power off
ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6234 power off
ipmitool -I lanplus -U admin -P Wond3rfulWorld -H 192.168.2.242 -p 6235 power off
ipmitool -I lanplus -U root -P calvin -H 192.168.2.231 -p 623 power off
ipmitool -I lanplus -U root -P calvin -H 192.168.2.232 -p 623 power off

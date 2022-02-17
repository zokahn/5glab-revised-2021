#version=RHEL8
# Use graphical install
graphical

repo --name="AppStream" --baseurl=file:///run/install/sources/mount-0000-cdrom/AppStream

%packages
@^minimal-environment
kexec-tools

%end

# Keyboard layouts
keyboard --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eno1 --ipv6=auto --activate
network  --hostname=nuc.simpletest.local

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=nvme0n1
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part pv.1034 --fstype="lvmpv" --ondisk=nvme0n1 --size=952244
part /boot --fstype="xfs" --ondisk=nvme0n1 --size=1024
part /boot/efi --fstype="efi" --ondisk=nvme0n1 --size=600 --fsoptions="umask=0077,shortname=winnt"
volgroup rhel_nuc --pesize=4096 pv.1034
logvol swap --fstype="swap" --size=16082 --name=swap --vgname=rhel_nuc
logvol / --fstype="xfs" --size=936156 --name=root --vgname=rhel_nuc

# System timezone
timezone Europe/Amsterdam --isUtc

#Root password
rootpw --lock
user --groups=wheel --name=bvandenh --password=$6$Q.ajpncZ3WJBWPvB$Pd3XPuwjjIlrosOG9lAr7QXBpZDC2ZXMF36oAn2Pt6Jr9ngvttC74revjkX/aH7ONxxa1Y/Q9.tl8JV.NafTG. --iscrypted --gecos="bvandenh"

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

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
network  --bootproto=dhcp --device=enp1s0 --ipv6=auto --activate
network  --bootproto=dhcp --device=enp2s0 --onboot=off --ipv6=auto
network  --hostname=localhost.localdomain

# Use CDROM installation media
cdrom

# Run the Setup Agent on first boot
firstboot --enable

ignoredisk --only-use=nvme0n1
# Partition clearing information
clearpart --none --initlabel
# Disk partitioning information
part /boot --fstype="xfs" --ondisk=nvme0n1 --size=1024
part pv.331 --fstype="lvmpv" --ondisk=nvme0n1 --size=952844
volgroup rhel --pesize=4096 pv.331
logvol / --fstype="xfs" --size=948744 --name=root --vgname=rhel
logvol swap --fstype="swap" --size=4096 --name=swap --vgname=rhel

# System timezone
timezone Europe/Amsterdam --isUtc

# Root password
rootpw --iscrypted $6$aluTmofPaFjWsCGz$9ahBKyd4Xst86zMbGsGAeEWeIYqUmcQqlVlyx8/nyBE4OUgYUBlCxLr6DQcO6eGKhLh4rUsWhUSAgJ2XOKC0I/

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

#!/bin/bash


cat > /etc/dnsmasq.d/dns.dnsmasq << EOF
domain-needed
bind-dynamic
bogus-priv
domain=simpletest.nl
resolv-file=/etc/resolv-dnsmasq.conf
expand-hosts
interface=baremetal
no-hosts
addn-hosts=/etc/hosts.dnsmasq
resolv-file=/etc/resolv.dnsmasq
cache-size=1000
local-ttl=300
address=/.apps.openshift.simpletest.nl/10.0.11.19
EOF

cat > /etc/resolv.dnsmasq << EOF
search openshift.simpletest.nl
nameserver 1.1.1.1
nameserver 8.8.8.8
EOF

cat > /etc/hosts.dnsmasq << EOF
10.0.11.18 api.openshift.simpletest.nl
EOF

cat > /etc/dnsmasq.d/dhcp.dnsmasq << 'EOF'
domain-needed
bind-dynamic
bogus-priv
log-queries
log-dhcp
dhcp-authoritative
dhcp-range=10.0.11.1,10.0.11.27
dhcp-option=3,10.0.11.30
dhcp-option=42,10.0.11.30
dhcp-host=52:54:00:15:cd:2f,openshift-master-0.simpletest.nl,10.0.11.2
dhcp-host=52:54:00:25:cd:2f,openshift-master-1.simpletest.nl,10.0.11.3
dhcp-host=52:54:00:35:cd:2f,openshift-master-2.simpletest.nl,10.0.11.4
dhcp-host=52:54:00:45:cd:2f,openshift-worker-0.simpletest.nl,10.0.11.5
dhcp-host=52:54:00:55:cd:2f,openshift-worker-1.simpletest.nl,10.0.11.6
dhcp-host=52:54:00:65:cd:2f,openshift-worker-2.simpletest.nl,10.0.11.7
dhcp-host=ec:f4:bb:dd:49:35,openshift-worker-3.simpletest.nl,10.0.11.8
dhcp-host=ec:f4:bb:dd:96:29,openshift-worker-4.simpletest.nl,10.0.11.9
# dhcp-ignore=tag:!known
EOF

dnsmasq --test
if [[ "$?" == "0" ]]; then
        systemctl is-active dnsmasq && systemctl restart dnsmasq
        systemctl is-enabled dnsmasq || systemctl enable --now dnsmasq
fi

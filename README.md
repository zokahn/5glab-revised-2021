# 5glab-revised-2021
OpenShift 4 BareMetal deploy focussed on NFV - Fede gear integrated with Zokahn gear, seeing what makes sense in terms of what keep and what to sell. Use-cases, power consumption, network throughput, deployment mechanism.

The lab runs in my shed, at my house. It is integrated in my home network and impacts my powerbill and my gadget budget ;-) In my work for Red Hat i am assigned to project at our Telecom customers. My drive is to learn, in depht, on how the Red Hat technology is used and is best implemented at Telco customers. Mainly to calm my nerves and be well prepared and while i do that power the increase of knowlegde and experience of the wider Red Hat Services organization in a to be formed OpenShift for Infra focussed folks.

The scope of this group is still being defined but focus is on:
- How demanding workloads in terms of performance work well on OpenShift
- How specific hardware features are exposed to workloads running in pods
- How networking technologies are offered to workloads
- What typical infrastructure focussed tools and services are helpful around OpenShift 4 implementations
- Result of the work is funneled into articles, ansible automation in git repositories.

## 5G OpenShift cluster as designed by m4r1k
https://github.com/m4r1k/k8s_5g_lab

Zokahn was able to acquire the 5G lab from m4r1k is this repo is to collect written documents, diagrams and code taking the k8s_5g_lab as a base, with the following focus points:

- Automated deploy of required components as frequently deployed by 5G telco operators for deployement and day2 operations
- Automated deploy of OpenShift4 masters and innitial workers using Red Hat deploy programs, disconnected, baremetal
- Extending the innitial cluster with additional machinesets to enroll new baremetal types
- Add various extensions of OpenShift 4 specific for 5G Telco with
  - MachineConfig
  - Multus in various mode (network attachments, macvlan, complete nic)
  - NMState
  - SR-IOV
  - MetalLB
  - PAO Operator

No more VMware. m4r1k decided to run virtualisation components based on VMware while the expertise of zokahn is focused on libvirt, kvm based virtualisation. For now the choice is made to see how far the train will push with kvm.

### Todo or not a focus for now
- Local storage on workers for now

In the near future the following topics will also be covered

  - FD.IO VPP App
  - Use an external CA for the entire platform
  - MetalLB BGP
  - Contour
  - CNV
  - Rook

## 2 - 5G is Containers
From [Ericsson](https://www.ericsson.com/en/cloud-native) to [Nokia](https://www.nokia.com/blog/containers-and-the-evolving-5g-cloud-native-journey/), from [Red Hat](https://www.redhat.com/en/blog/5g-core-adoption-open-way-red-hat-openshift?source=bloglisting&page=1&search=5g+openshift) to [VMware](https://www.fiercewireless.com/tech/samsung-vmware-team-cloud-native-5g-functions), and with leading examples like [Verizon](https://www.fiercewireless.com/tech/verizon-readies-initial-shift-to-5g-standalone-core-after-successful-trial) and [Rakuten](https://www.fiercewireless.com/5g/rakuten-s-5g-network-will-be-built-containers), there is absolutely no douth that 5G means containers, and as everybody knows, containers mean Kubernetes. There are many debates whether the more significant chunk of the final architecture would be virtualized or natively running on bare-metal (there are still some cases where hardware virtualization is a fundamental need) but, in all instances, Kubernetes is the dominant and de-facto standard to build applications.

Operating in a containerized cloud-native world represents such a significant shift for all Telco operators that the NFVi LEGO approach seems easy now.

For those who have any doubts about the capability of Kubernetes to run an entire mobile network, I encourage you to watch:

* [KubeCon NA 2019 Keynote](https://www.youtube.com/watch?v=IL4nxbmUIX8) - [Slides](https://static.sched.com/hosted_files/kccncna19/c9/5%20HEATHER%20KIRKSEY%20-%20V3.pptx.pdf)
* [Build Your Own Private 5G Network on Kubernetes](https://www.youtube.com/watch?v=R_JOhWlwsXo) - [Slides](https://static.sched.com/hosted_files/kccncna19/02/KubeCon%202019%20-%20BYO%205G%20Network.pdf)

### 2.1 - Why Bare-metal?
To answer this question, you need to keep in mind the target workloads: Cloud-native Network Function (CNF) such as UPF for 5G Core and vDU in RAN. [Red Hat has a great whitepaper](https://www.redhat.com/en/resources/optimize-5g-with-containers-on-bare-metal-whitepaper) talking about all the details, especially how performance is negatively affected by a hardware virtualization layer. [Yet other examples from Red Hat](https://www.redhat.com/en/blog/red-hat-openshift-drives-strong-5g-open-ran-ecosystem) in the [Radio context](https://www.redhat.com/en/blog/kubernetes-bare-metal-future-ran). But if Red Hat is not enough, well, [let's look at Ericsson](https://www.ericsson.com/en/blog/2020/3/benefits-of-kubernetes-on-bare-metal-cloud-infrastructure) talking about the advantages of cloud-native on bare-metal.

## 3 - About this document
The primary aim for this document is deploying a 5G Telco Lab using mix of virtual and physical components. Several technical choices - combination of virtual/physical, NFS server, *limited* resources for the OpenShift Master, some virtual Worker nodes, etc - are just compromises to cope with the Lab resources. *As a reference, all this stuff runs at my home*.

Everything that is built on top of the virtualization stack is explained in greater detail.

**<div align="center"><span style="color:red">For the sake of explanation, limited automation is provided</span></div>**

Once Talos Linux and the needed base pre-requisites are completed, ArgoCD will then be configured.

Process
- [ ] ArgoCD managed base cluster configs
	- [ ] Infisical installed via Helm - [Docs](https://infisical.com/docs/integrations/platforms/kubernetes/overview)
	- [ ] Ceph for PV's
		- [ ] Ceph RBD - [Docs](https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-rbd)
		- [ ] CephFS - [Docs](https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-cephfs)
	- [ ] CSI Driver for SMB via Helm - [Docs](https://github.com/kubernetes-csi/csi-driver-smb/tree/master/charts)
	- [ ] 
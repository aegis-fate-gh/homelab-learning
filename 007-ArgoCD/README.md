Once Talos Linux and the needed base pre-requisites are completed, ArgoCD will then be configured with Terraform.

Process
- [x] Deploy ArgoCD
	- [x] Get valid HTTPS cert with local only domain
	- [x] Set up ArgoCD Rolebinding
- [ ] ArgoCD managed base cluster configs
	- [ ] Ceph CSI's for PV's
		- [ ] Push needed secrets to cluster via TF
		- [ ] Ceph RBD - [Docs](https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-rbd) - For containers with DB's
		- [ ] CephFS - [Docs](https://github.com/ceph/ceph-csi/tree/devel/charts/ceph-csi-cephfs) - For everything else
		- [ ] Create snapshot classes for both
	- [ ] Deploy Snapshot and Volume Group CRD's
	- [ ] Deploy Common Snapshot controller
	- [ ] Deploy Infisical via Helm - [Docs](https://infisical.com/docs/self-hosting/deployment-options/kubernetes-helm)
	- [ ] Deploy Infiisical operator via Helm - [Docs](https://infisical.com/docs/integrations/platforms/kubernetes/overview)
	- [ ] Deploy CSI Driver for SMB via Helm - [Docs](https://github.com/kubernetes-csi/csi-driver-smb/tree/master/charts)
	- [ ] Deploy Volsync via Helm
	- [ ] Create Namespaces
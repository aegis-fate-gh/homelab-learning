
### Talos Setup via UI
Base Docs: https://docs.siderolabs.com/talos/v1.14/platform-specific-installations/virtualized-platforms/proxmox

ISO Download URL: https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.14.5/nocloud-amd64.iso

Install Link: factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.14.5

Step 4:
```
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out --install-image factory.talos.dev/nocloud-installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.14.5
```

Step 5: Multiple control plane nodes at once
Apply to a single node first, wait for it to show as ready
```
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml
```

Once the first node is ready, you can apply the config to the other nodes. 
```
talosctl apply-config --insecure --nodes 192.168.7.83,192.168.7.115 --file _out/controlplane.yaml
```

Note, failing to wait for the first node to be ready can result in needing to wipe the node state.....
```
talosctl -n 192.168.7.83 reset --graceful=false --reboot \ --system-labels-to-wipe STATE --system-labels-to-wipe EPHEMERAL
```

And once that's completed, they will need to be rebuilt, and then the old nodes will then need to be removed from the cluster via kubectl...
```
kubectl delete node talos-87x-0f3
```

Step 6: Multiple worker nodes at once
```
talosctl apply-config --insecure --nodes 192.168.7.44,192.168.7.183,192.168.7.191 --file _out/worker.yaml
```


Status as of 11/10/26
- [x] Custom Image Created with qemu-agent - [Docs](https://docs.siderolabs.com/talos/v1.14/learn-more/image-factory)
- [x] 6 VM's (3 Worker, 3 Control Plane) created on Andromeda via UI
- [x] Base cluster in a healthy state
- [x] Shutdown and delete cluster
- [ ] Create working VM's with OpenTofu
	- [x] Create Mac Addresses via IT Tools
	- [x] Create static IP's for those addresses in Unifi - [Docs](https://search.opentofu.org/provider/ubiquiti-community/unifi/latest) - 01
		- [x] Create user with permissions to only the network app
	- [x] Create VM's in Proxmox - [Docs](https://search.opentofu.org/provider/bpg/proxmox/latest) - 02
		- [x] Create new Proxmox Group
		- [x] Create Proxmox user
		- [x] Add the user to the desired role
		- [x] Create API Token
		- [x] Save token and token ID to Infisical
		- [x] Create VM's
- [ ] Build working Talos cluster on Proxmox with OpenTofu 
	- [ ] Configure vm's and bootstrap working cluster - [Docs](https://search.opentofu.org/provider/siderolabs/talos/latest) - 03
- [ ] Rebuild Cluster with no CNI, the Proxy Disabled, and kubePrism enabled (Enabled is the default) - [Docs ](https://docs.siderolabs.com/kubernetes-guides/cni/deploying-cilium#without-kube-proxy)
- [ ] OpenTofu using Infisical Secrets - [Kubernetes Provider](https://search.opentofu.org/provider/opentofu/kubernetes/latest), [Helm Provider](https://search.opentofu.org/provider/opentofu/helm/latest)
	- [ ] Cilium working for ingress, gateway API, and L2 Announcements
		- [ ] Set up Gateway API CRD's
		- [ ] Install Cilium via Helm
	- [ ] Install Cert-manager and ClusterIssuer for Cloudflare
	- [ ] Install Snapshot and Volume Group CRD's
	- [ ] Install Common Snapshot controller
	- [ ] ArgoCD Install and setup via Helm
		- [ ] HTTPS setup with static IP
		- [ ] Connect to learning repo
		- [ ] Connect to Forgejo
		- [ ] Rolebinding setup

Once the Above is completed, the multi cluster test starts
- [ ] Create second working Talos cluster in a different VLAN
- [ ] Connect ArgoCD to second cluster - [Docs](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#clusters)
- [ ] Deploy 
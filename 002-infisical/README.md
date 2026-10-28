#### Premise 
Currently credentials within my homelab are managed in multiple places. For kubernetes they come from an ansible playbook that creates the actual secrets in the cluster. Within Docker, they're within multiple environment files that are just blocked from synching to Github.

Both work well but I'm me, which means there's inherently a desire to see if I can centralize and simplify things, and enable someone besides me to understand and make use of my homelab in a self service fashion.

#### Current Setup
For the sake of learning and integrating things without much additional complexity, the current (As of 10/26/26) setup has Infisical running on the Polaris Docker node, with Portainer managing it. The image tag is also being kept as latest for testing.
#### Future Plans
The plan is to integrate Infisical with [Docker](https://infisical.com/docs/integrations/platforms/docker#fetch-at-startup-recommended), [Ansible](https://infisical.com/docs/integrations/platforms/ansible), [OpenTofu](https://infisical.com/blog/opentofu-secrets-management-with-infisical#running-this-in-cicd-github-actions-example), and [Kubernetes](https://infisical.com/docs/documentation/guides/kubernetes-operator#create-the-dynamic-secret-in-infisical). As noted above, the goal is for it to be the source of truth for passwords and other credentials across my entire homelab.

#### Notes
The ENV variables in use in the compose file are the current required values. While the documentation notes that fewer are required, this is not the case.
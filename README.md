# hugoplanet-infra-lab

Infrastructure configuration for the home Kubernetes lab that is driven by
Helm charts and Argo CD.

## Secrets management with SOPS

This repository now ships with a SOPS-based workflow that keeps sensitive
values encrypted at rest while still being deployable through Helm/Argo CD.
It is composed of two charts that are managed via the existing
`apps` application-of-apps chart:

- `charts/sops-secrets-operator`: installs the
  [sops-secrets-operator](https://github.com/isindir/sops-secrets-operator)
  and wires it up with an Age key so that `SopsSecret` custom resources can be
  reconciled cluster-wide.
- `charts/cluster-secrets`: packages your encrypted `SopsSecret` manifests and
  applies them. The operator decrypts their payloads and keeps the resulting
  `Secret` objects in sync across namespaces.

### Bootstrap checklist

1. **Generate an Age key pair** (Age stores both private and public material in
   the same file):
   ```bash
   age-keygen -o age.agekey
   grep "^# public key:" age.agekey | awk '{print $4}'
   ```
2. **Update `.sops.yaml`** with the Age public key from the previous command so
   that new files are encrypted for the right recipients.
3. **Create the Age private key secret** that will be mounted by the operator:
   ```bash
   kubectl create namespace sops
   kubectl create secret generic sops-age-key \
     --namespace sops \
     --from-file=key.txt=age.agekey
   ```
   The operator chart mounts `/etc/sops-age/key.txt` and exposes it via the
   `SOPS_AGE_KEY_FILE` environment variable.
4. **Purge the local private key file (`age.agekey`)** or store it securely. You
   will need it (or another key holder) whenever you encrypt or decrypt secrets
   locally.

### Adding new encrypted secrets

Every secret bundle lives as its own `SopsSecret` manifest under
`charts/cluster-secrets/secrets/`. The `.gitkeep` file ensures the directory is
tracked until you add the first secret.

1. Create a plain-text manifest, for example:
   ```yaml
   apiVersion: isindir.github.com/v1alpha3
   kind: SopsSecret
   metadata:
     name: default-secrets
     namespace: sops
   spec:
     secretTemplates:
       - name: sample-app
         namespace: default
         stringData:
           username: changeme
           password: changeme
   ```
   The `namespace` field under `secretTemplates` controls where the resulting
   Kubernetes `Secret` will be written.
2. Encrypt the file. The `.sops.yaml` config instructs SOPS to protect the
   entire `secretTemplates` section as well as the traditional `stringData` /
   `data` fields:
   ```bash
   sops --encrypt --in-place charts/cluster-secrets/secrets/default-secrets.yaml
   ```
3. Commit the encrypted file (it will now contain `ENC[...]` values and a `sops`
   metadata block). The chart automatically bundles every `*.yaml` / `*.yml`
   file from that directory into the release.

Use `sops -d <path>` whenever you need to inspect or edit the cleartext
content. All changes should be committed in encrypted form only.

### Deploying

- Argo CD receives two new Applications (`sops-secrets-operator` and
  `cluster-secrets`). Sync waves ensure that the operator (wave `0`) comes up
  before the encrypted secrets (wave `1`).
- When running Helm manually, the same ordering can be achieved with:
  ```bash
  helm dependency update charts/sops-secrets-operator
  helm upgrade --install sops-operator charts/sops-secrets-operator
  helm upgrade --install cluster-secrets charts/cluster-secrets
  ```
- If Argo CD is already managing the cluster, simply commit your encrypted
  secrets to `main`; the controller will take care of reconciling them.

### Helpful commands

```bash
# Decrypt for local inspection
sops -d charts/cluster-secrets/secrets/default-secrets.yaml

# Add a new recipient to all encrypted bundles
sops --add-age <AGE_PUBLIC_KEY> charts/cluster-secrets/secrets/*.yaml
```

Keep the private Age key safe—anyone with access to it can decrypt every secret
that follows this scheme.

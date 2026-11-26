# Traefik (owned by k3s)

Traefik is no longer managed by helmfile. k3s installs and upgrades Traefik via
its bundled HelmChart (`traefik`) and the `HelmChartConfig` in `kube-system`;
k3s's helm-controller is the single owner of the release. The helmfile
`traefik` release is removed.

## Migration

1. Merge the PR that removes the helmfile `traefik` release. The already-running
   helm release (36.0.0) stays up as an orphan; helmfile no longer touches it.
2. Upgrade k3s 1.32 → 1.37.2 one minor at a time. The first k3s version change
   re-applies the bundled `traefik` HelmChart, and k3s's helm-controller becomes
   the owner of the release. The existing (mail-ports) `HelmChartConfig` keeps
   mail working throughout.
3. After k3s reaches 1.37.2, copy `traefik/HelmChartConfig-migration.yaml` to
   the k3s **server** node at
   `/var/lib/rancher/k3s/server/manifests/traefik-config.yaml` (or
   `kubectl apply` it). It supersedes the mail-only HelmChartConfig. k3s re-runs
   the deploy job with the full config (resources, tolerations, metrics,
   Cloudflare trusted IPs, mail ports).

## Notes

- k3s 1.37.2 bundles chart 42.x / Traefik 3.7.15.
- `traefik/values.yaml.gotmpl` is deprecated (no longer consumed by helmfile)
  but kept as the source of truth for the values mirrored into the
  HelmChartConfig.
- To pin a different Traefik image, set `image.tag` (e.g. `"3.7.19"`) in the
  HelmChartConfig `valuesContent`.
- The Cloudflare `forwardedHeaders.trustedIPs` lists in the HelmChartConfig are
  static; refresh them periodically from
  <https://www.cloudflare.com/ips-v4> and <https://www.cloudflare.com/ips-v6>.

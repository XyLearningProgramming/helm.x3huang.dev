# Traefik (owned by k3s)

Traefik is no longer managed by helmfile. k3s installs and upgrades Traefik via
its bundled HelmChart (`traefik`) and the `HelmChartConfig` in `kube-system`;
k3s's helm-controller is the single owner of the release. The helmfile
`traefik` release is removed.

## Migration

1. Copy `traefik/HelmChartConfig-migration.yaml` to the k3s **server** node at
   `/var/lib/rancher/k3s/server/manifests/traefik-config.yaml` **before**
   merging the PR that removes the helmfile traefik release. k3s's controller
   will then deploy Traefik with the full config as it takes over.
2. Merge the PR and remove the old helmfile-managed release from the cluster.

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

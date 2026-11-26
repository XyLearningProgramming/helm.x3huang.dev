# Traefik (owned by k3s)

Traefik is installed and upgraded by **k3s itself** via the bundled `HelmChart`
(`traefik` + `traefik-crd`) and the `HelmChartConfig` in `kube-system`.
k3s's helm-controller is the single owner of the release. **helmfile does not
manage Traefik** — there is deliberately no `traefik` release in
`helmfile.yaml.gotmpl`, and the `traefik` chart repository is not declared.

## Steady state

- `HelmChartConfig.yaml` is the **canonical copy** of the values applied on the
  k3s **server** node. To change Traefik settings: edit that file, then
  `kubectl apply -f traefik/HelmChartConfig.yaml` (or copy it to
  `/var/lib/rancher/k3s/server/manifests/traefik-config.yaml` on the server).
- k3s version changes re-apply the bundled chart; these values are merged on
  top and survive k3s upgrades.

## Notes

- k3s 1.37.2 bundles chart 42.x / Traefik 3.7.15. To pin a different image,
  set `image.tag` (e.g. `"3.7.19"`) in the HelmChartConfig `valuesContent`.
- The Cloudflare `forwardedHeaders.trustedIPs` lists in the HelmChartConfig
  are static; refresh them periodically from
  <https://www.cloudflare.com/ips-v4> and <https://www.cloudflare.com/ips-v6>.
- The dead `traefik:` block that historically sat in
  `/etc/rancher/k3s/config.yaml` was removed during the 2026-11 cleanup — k3s
  never consumed it; live values come only from the HelmChartConfig.
- The pre-migration helmfile values (`traefik/values.yaml.gotmpl`) were removed
  after the migration completed; git history retains them if ever needed.
- `traefik-dashboard/` is an on-demand debug helper (Ingress + Service +
  apply script), intentionally not part of any chart.

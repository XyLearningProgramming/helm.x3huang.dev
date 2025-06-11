# helm.x3huang.dev

This repository manages all `helm` charts for my personal site for blogging [x3huang.dev](https://x3huang.dev) using `helmfile`.  
Deployments are automated via CI/CD pipelines that deploy to a VPS over HTTP so that **ALL** infra of the site can be reproduced anywhere, anytime, explicitly.

## Features

- **Declarative Management**: Use `helmfile` to declare, manage, and deploy multiple Helm charts.
- **Automated CI/CD**: Integration with GitHub Actions for continuous delivery.
- **Env Values and Secrets Management**: Use values differ by environment in `./values` and injected by helmfile. Secrets are injected by workflow.

## Architecture

The infrastructure consists of several key components:

### Core Components
- **TLS Certificates** (`ingress-cert/`): Automatic SSL/TLS certificate management
- **Monitoring Stack** (`prom-stack/`): Prometheus, Grafana, and exporters for system monitoring
- **Example Application** (`dummy-page/`): Reference implementation with ingress configuration
- **Ingress Controller** (`kube-system/`): Traefik-based ingress management

### Monitoring Dashboard
![VPS Monitoring Dashboard](docs/vps-monitoring-2025-05-29-1726.png)

## Prerequisites

- `helm` >= v3.17.3
- `helmfile` >= v1.0.0

``` bash
❯ kubectl version
Client Version: v1.32.4+k3s1
Kustomize Version: v5.5.0
Server Version: v1.32.4+k3s1
```

## Comments

1. Need to install some CRDs manually if not installed at least once before.
2. Change `./values` if domain name changes.
3. Add files in `./secrets` as secrets in workflow.
4. Run `sudo mount --make-shared /` so that prom. node exporter container can start successfully.
5. Traefik config is managed by k3s. So... remove traefik in k3s installed by default.

```bash
# Ref: https://qdnqn.com/k3s-remove-traefik/
sudo rm -rf /var/lib/rancher/k3s/server/manifests/traefik.yaml
helm uninstall traefik traefik-crd -n kube-system
sudo systemctl restart k3s
```

6. Run these commands to make sure pv path exists (for mail deployment)

```bash
mkdir -p /var/log/mail
mkdir -p /var/mail-state
mkdir -p /var/mail
mkdir -p /tmp/docker-mailserver
```

7. Default coredns have these error logs without custom configs, comment out these lines to avoid them from being emitted.

Ref: https://github.com/k3s-io/k3s/issues/7639#issuecomment-1592172869

```log
[WARNING] No files matching import glob pattern: /etc/coredns/custom/*.override 
[WARNING] No files matching import glob pattern: /etc/coredns/custom/*.server 
```

```yaml
# /var/lib/rancher/k3s/server/manifests/coredns.yaml
data:
  Corefile: |
    .:53 {
        # ...
        # import /etc/coredns/custom/*.override
    }
    # import /etc/coredns/custom/*.server
```

```bash
sudo vim /var/lib/rancher/k3s/server/manifests/coredns.yaml
kubectl rollout restart deployment coredns -n kube-system
```

## Helpers

```bash
# Render mailserver to helm chart
helmfile -e prod template --output-dir rendered
```

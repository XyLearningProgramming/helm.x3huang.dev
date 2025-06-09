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
5. Traefik config is managed by k3s since I do not install another one. So... ALL entrypoints are configured in `/var/lib/rancher/k3s/server/manifests/traefik-config.yaml` inside the main host.

```yaml
# /var/lib/rancher/k3s/server/manifests/traefik-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik       # must exactly match the HelmChart name
  namespace: kube-system
spec:
  valuesContent: |-
    additionalArguments:
    - "--log.level=DEBUG"
    - "--accesslog=true"

    ########################################
    ## 1) METRICS (Prometheus)             ##
    ########################################
    metrics:
      prometheus:
        enabled: true

    ########################################
    ## 2) ENTRYPOINT DEFINITIONS           ##
    ########################################
    # Define only the actual mail entryPoints.  Proxy ports are resolved later by IngressRouteTCP.
    entryPoints:
      mail-smtp:
        address: ":25"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-sb:
        address: ":587"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-sbs:
        address: ":465"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-imap:
        address: ":143"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-imaps:
        address: ":993"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-pop3:
        address: ":110"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"
      mail-pop3s:
        address: ":995"
        proxyProtocol:
          trustedIPs:
            - "0.0.0.0/0"

    ########################################
    ## 3) EXPOSED PORTS                    ##
    ########################################
    # Map only the original mail ports.  IngressRouteTCP will bind proxy ports internally.
    ports:
      mail-smtp:
        port: 25
        expose:
          default: true
        exposedPort: 25
        protocol: TCP

      mail-sb:
        port: 587
        expose:
          default: true
        exposedPort: 587
        protocol: TCP
      mail-sbs:
        port: 465
        expose:
          default: true
        exposedPort: 465
        protocol: TCP

      mail-imap:
        port: 143
        expose:
          default: true
        exposedPort: 143
        protocol: TCP
      mail-imaps:
        port: 993
        expose:
          default: true
        exposedPort: 993
        protocol: TCP

      mail-pop3:
        port: 110
        expose:
          default: true
        exposedPort: 110
        protocol: TCP
      mail-pop3s:
        port: 995
        expose:
          default: true
        exposedPort: 995
        protocol: TCP

```

6. Run these commands to make sure pv path exists (for mail deployment)

```bash
mkdir -p /var/log/mail
mkdir -p /var/mail-state
mkdir -p /var/mail
mkdir -p /tmp/docker-mailserver
```

## Helpers

```bash
# Render mailserver to helm chart
helmfile -e prod template --output-dir rendered
```

# helm.x3huang.dev

This repository manages all `helm` charts for my personal site for blogging [x3huang.dev](https://x3huang.dev) using `helmfile`.  
Deployments are automated via CI/CD pipelines that deploy to a VPS over HTTP.

## Features

- **Declarative Management**: Use `helmfile` to declare, manage, and deploy multiple Helm charts.
- **Automated CI/CD**: Integration with GitHub Actions for continuous delivery.
- **Streamlined Workflow**: `helmfile` commands for rendering and applying configurations.
- **Env Values and Secrets Management**: Use values differ by environment in `./values` and injected by helmfile.

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

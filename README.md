# helm.x3huang.dev

This repository manages the Kubernetes infrastructure for [x3huang.dev](https://x3huang.dev) using `helmfile` and Helm charts. It provides a declarative and reproducible way to deploy the entire infrastructure stack, including TLS certificates, monitoring, and web services.

## Features

- **Declarative Infrastructure**: Define and manage multiple Helm charts using `helmfile`
- **Automated CI/CD**: GitHub Actions pipelines for continuous delivery to VPS
- **Environment Management**: Separate value files for different environments in `./values`
- **Secret Management**: Secure handling of secrets through CI/CD workflows

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
- Kubernetes cluster (tested with k3s v1.32.4)

```bash
❯ kubectl version
Client Version: v1.32.4+k3s1
Kustomize Version: v5.5.0
Server Version: v1.32.4+k3s1
```

## Project Structure

```
.
├── values/          # Environment-specific values
│   ├── default.yaml
│   └── prod.yaml
├── secrets/         # Secret templates and examples
├── dummy-page/      # Example application chart
├── ingress-cert/    # Certificate management chart
├── kube-system/     # System components
├── prom-stack/      # Monitoring stack
└── scripts/         # Utility scripts
```

## Setup Instructions

1. Clone this repository
2. Install required CRDs for cert-manager and prometheus-operator
3. Configure domain settings in `./values/`
4. Set up secrets in your CI/CD workflow
5. Run the following on the host for node-exporter:
   ```bash
   sudo mount --make-shared /
   ```

## Configuration

### Environment Values
- Environment-specific configurations are stored in `./values/`
- Update domain settings in these files when deploying to a new environment

### Secrets Management
1. Copy `./secrets/monitoring.example.env` to `./secrets/monitoring.env`
2. Add the required secrets to your CI/CD workflow
3. Secrets are automatically injected during deployment

## Future Enhancements

- [ ] SMTP integration
- [ ] Enhanced monitoring dashboards
- [ ] Backup solution

## Troubleshooting

1. **Node Exporter Issues**: Ensure shared mount is configured:
   ```bash
   sudo mount --make-shared /
   ```
2. **CRD Installation**: Some CRDs need manual installation on first deployment
3. **Certificate Issues**: Verify cluster-issuer and DNS settings in `./values/`

## Extra charts for kube-system

### traefik-config.yaml for k3s
```
# var/lib/rancher/k3s/server/manifests/traefik-config.yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik       # must exactly match the HelmChart name
  namespace: kube-system
spec:
  valuesContent: |-
    ########################################
    ## 1) METRICS (Prometheus) ENTRYPOINT ##
    ########################################

    # Enable Prometheus metrics in Traefik and bind its entryPoint to :8082
    metrics:
      prometheus:
        enabled: true
        # This tells Traefik which entryPoint to use for Prometheus metrics
        entryPoint: metrics

    ################################################################
    ## 2) ADDITIONAL ARGUMENTS (all entryPoints listed below)    ##
    ################################################################

    # Each "––entryPoints.<name>.address=:<port>" line tells Traefik's pod to bind
    # that entryPoint on the given port inside the container.
    # We also pass proxyProtocol.trustedIPs for each mail entryPoint.
    additionalArguments:
      # Metrics address is found via k3s dns directly.
      # # ─── METRICS ENTRYPOINT ──────────────────────────────────────────
      # - "--entryPoints.metrics.address=:9100"

      # ─── MAIL ENTRYPOINTS ────────────────────────────────────────────
      - "--entryPoints.mail-smtp.address=:25"
      - "--entryPoints.mail-smtp.proxyProtocol.trustedIPs=0.0.0.0/0"
      - "--entryPoints.mail-submission.address=:587"
      - "--entryPoints.mail-submission.proxyProtocol.trustedIPs=0.0.0.0/0"
      - "--entryPoints.mail-imaps.address=:993"
      - "--entryPoints.mail-imaps.proxyProtocol.trustedIPs=0.0.0.0/0"
      - "--entryPoints.mail-pop3s.address=:995"
      - "--entryPoints.mail-pop3s.proxyProtocol.trustedIPs=0.0.0.0/0"

    ############################################################
    ## 3) EXPOSED PORTS (map each entryPoint → external port) ##
    ############################################################

    # Under "ports:" we declare which ports Traefik’s Service object should open on each Node,
    # and how they map back to the containerPort (the same value, in this case).
    ports:
      # # ─── METRICS PORT ───────────────────────────────────────────────
      # metrics:
      #   port: 9100
      #   expose:
      #     default: true
      #   exposedPort: 9100
      #   protocol: TCP

      # ─── MAIL: SMTP (25) ────────────────────────────────────────────
      mail-smtp:
        port: 25
        expose:
          default: true
        exposedPort: 25
        protocol: TCP

      # ─── MAIL: Submission (587) ────────────────────────────────────
      mail-submission:
        port: 587
        expose:
          default: true
        exposedPort: 587
        protocol: TCP

      # ─── MAIL: IMAPS (993) ─────────────────────────────────────────
      mail-imaps:
        port: 993
        expose:
          default: true
        exposedPort: 993
        protocol: TCP

      # ─── MAIL: POP3S (995) ─────────────────────────────────────────
      mail-pop3s:
        port: 995
        expose:
          default: true
        exposedPort: 995
        protocol: TCP

```
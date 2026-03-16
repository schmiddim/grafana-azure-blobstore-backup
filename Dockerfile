# Grafana Dashboard Sync Tool
# Base: Azure CLI with grafanactl for Grafana 12+ dashboard backup/restore
#
# Renovate will auto-update these images when configured with:
#   "dockerfile": { "fileMatch": ["Dockerfile"] }

# ============================================================================
# Stage 1: Download grafanactl binary
# ============================================================================
# renovate: datasource=github-releases depName=grafana/grafana-cli
ARG GRAFANACTL_VERSION=v0.6.1

FROM alpine:3.21 AS downloader

ARG GRAFANACTL_VERSION
ARG TARGETARCH

RUN apk add --no-cache curl tar

# Download grafanactl for the target architecture
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) ARCH="linux_amd64" ;; \
        arm64) ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    VERSION="${GRAFANACTL_VERSION#v}"; \
    curl -fsSL "https://github.com/grafana/grafana-cli/releases/download/${GRAFANACTL_VERSION}/grafanactl_${VERSION}_${ARCH}.tar.gz" \
        | tar -xz -C /tmp; \
    chmod +x /tmp/grafanactl

# ============================================================================
# Stage 2: Final image with Azure CLI + grafanactl
# ============================================================================
# renovate: datasource=docker depName=mcr.microsoft.com/azure-cli
FROM mcr.microsoft.com/azure-cli:2.68.0

LABEL org.opencontainers.image.title="grafana-backup"
LABEL org.opencontainers.image.description="Container with Azure CLI and grafanactl for Grafana dashboard backup/restore"

# Copy grafanactl from downloader stage
COPY --from=downloader /tmp/grafanactl /usr/local/bin/grafanactl

# Install jq for JSON processing
RUN apk add --no-cache jq bash

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]

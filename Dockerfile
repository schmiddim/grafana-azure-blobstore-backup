# Grafana Dashboard Sync Tool
# Base: Azure CLI with grafanactl for Grafana 12+ dashboard backup/restore
#
# Renovate will auto-update these images when configured with:
#   "dockerfile": { "fileMatch": ["Dockerfile"] }

# ============================================================================
# Stage 1: Download grafanactl binary
# ============================================================================
# Dependabot cannot track ARG versions - updated via update-grafanactl.yml workflow
ARG GRAFANACTL_VERSION=v0.1.9

FROM alpine:3.23 AS downloader

ARG GRAFANACTL_VERSION
ARG TARGETARCH

RUN apk add --no-cache curl tar

# Download grafanactl for the target architecture
# Repo: https://github.com/grafana/grafanactl
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) ARCH="Linux_x86_64" ;; \
        arm64) ARCH="Linux_arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/grafana/grafanactl/releases/download/${GRAFANACTL_VERSION}/grafanactl_${ARCH}.tar.gz" \
        | tar -xz -C /tmp; \
    chmod +x /tmp/grafanactl

# ============================================================================
# Stage 2: Final image with Azure CLI + grafanactl
# ============================================================================
# renovate: datasource=docker depName=mcr.microsoft.com/azure-cli
FROM mcr.microsoft.com/azure-cli:2.84.0

LABEL org.opencontainers.image.title="grafana-backup"
LABEL org.opencontainers.image.description="Container with Azure CLI and grafanactl for Grafana dashboard backup/restore"

# Copy grafanactl from downloader stage
COPY --from=downloader /tmp/grafanactl /usr/local/bin/grafanactl

# Install jq for JSON processing (azure-cli uses Mariner Linux with tdnf)
RUN tdnf install -y jq && tdnf clean all

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]

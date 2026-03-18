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
# Note: Using 'azurelinux3.0' tag for latest Azure CLI on Azure Linux 3.0
# Dependabot cannot track this rolling tag - manual updates may be needed
FROM mcr.microsoft.com/azure-cli:azurelinux3.0

LABEL org.opencontainers.image.title="grafana-backup"
LABEL org.opencontainers.image.description="Container with Azure CLI and grafanactl for Grafana dashboard backup/restore"

# Copy grafanactl from downloader stage
COPY --from=downloader /tmp/grafanactl /usr/local/bin/grafanactl

# Install curl and jq for JSON processing (azure-cli uses Mariner Linux with tdnf)
RUN tdnf install -y curl jq && tdnf clean all

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]

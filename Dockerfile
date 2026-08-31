# Grafana Dashboard Sync Tool
# Base: Azure CLI with gcx for Grafana 12+ dashboard backup/restore
#
# Renovate will auto-update these images when configured with:
#   "dockerfile": { "fileMatch": ["Dockerfile"] }

# ============================================================================
# Stage 1: Download gcx binary
# ============================================================================
# Dependabot cannot track ARG versions - updated via update-gcx.yml workflow
ARG GCX_VERSION=1.2.0

FROM alpine:3.24 AS downloader

ARG GCX_VERSION
ARG TARGETARCH

RUN apk add --no-cache curl tar

# Download gcx for the target architecture
# Repo: https://github.com/grafana/gcx
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) ARCH="linux_amd64" ;; \
        arm64) ARCH="linux_arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/grafana/gcx/releases/download/v${GCX_VERSION}/gcx_${GCX_VERSION}_${ARCH}.tar.gz" \
        | tar -xz -C /tmp; \
    chmod +x /tmp/gcx

# ============================================================================
# Stage 2: Final image with Azure CLI + gcx
# ============================================================================
# Note: Using 'azurelinux3.0' tag for latest Azure CLI on Azure Linux 3.0
# Dependabot cannot track this rolling tag - manual updates may be needed
FROM mcr.microsoft.com/azure-cli:azurelinux3.0

LABEL org.opencontainers.image.title="grafana-backup"
LABEL org.opencontainers.image.description="Container with Azure CLI and gcx for Grafana dashboard backup/restore"

# Copy gcx from downloader stage
COPY --from=downloader /tmp/gcx /usr/local/bin/gcx

# Install curl and jq for JSON processing (azure-cli uses Mariner Linux with tdnf)
RUN tdnf install -y curl jq && tdnf clean all

WORKDIR /workspace

ENTRYPOINT ["/bin/bash"]

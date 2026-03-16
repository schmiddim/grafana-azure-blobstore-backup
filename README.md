# grafana-backup

[![Docker Hub](https://img.shields.io/docker/v/schmiddim/grafana-azure-blobstore-backup?label=Docker%20Hub&logo=docker)](https://hub.docker.com/r/schmiddim/grafana-azure-blobstore-backup)

Container image with Azure CLI and grafanactl for Grafana 12+ dashboard operations.

## Contents

- **Azure CLI** - for Azure Blob Storage operations
- **grafanactl** - official Grafana CLI for dashboard export/import
- **jq** - JSON processing
- **bash** - scripting

## Build

```bash
docker build -t grafana-backup:latest .

# Multi-arch
docker buildx build --platform linux/amd64,linux/arm64 -t your-registry/grafana-backup:latest --push .
```

## Usage

```bash
docker run -it --rm \
  -e GRAFANA_URL=https://grafana.example.com \
  -e GRAFANA_TOKEN=glsa_xxx \
  grafana-backup:latest

# Inside container:
grafanactl resources list dashboards
az storage blob list --account-name xxx --container-name xxx
```

## Renovate

Configured for automatic updates of:
- Azure CLI base image
- grafanactl version

## Docker

```bash
docker pull schmiddim/grafana-azure-blobstore-backup:latest
```

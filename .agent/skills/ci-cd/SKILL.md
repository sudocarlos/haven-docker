---
name: ci-cd
description: CI/CD pipeline for haven-docker including the GitHub Actions workflow for GHCR publishing, the manual DockerHub release script, cosign image signing, and version management. Use when modifying build automation, release processes, or image signing.
---

# CI/CD

## GitHub Actions — `docker-publish.yml`

Located at `.github/workflows/docker-publish.yml`.

### Triggers

- **Schedule**: daily at 12:28 UTC
- **Push**: to `main` branch or semver tags (`v*.*.*`)
- **Pull request**: against `main`

### Pipeline steps

1. Checkout repo
2. Install cosign (skipped on PRs)
3. Set up Docker Buildx
4. Log into GHCR (`ghcr.io`) using `GITHUB_TOKEN`
5. Extract Docker metadata (tags, labels)
6. Build and push image (push skipped on PRs, uses GHA cache)
7. Sign image with cosign (skipped on PRs, uses Sigstore/Fulcio)

### Registry

- **GHCR**: `ghcr.io/sudocarlos/haven-docker` (automated via Actions)
- **DockerHub**: `sudocarlos/haven` (manual via `release-to-dockerhub.sh`)

## Manual DockerHub Release — `release-to-dockerhub.sh`

```bash
./release-to-dockerhub.sh
```

This script:
1. Extracts version from the `TAG=` line in `Dockerfile`
2. Builds with `docker buildx` (no cache), pushes `latest` + version tags
3. Commits all changes, creates an annotated git tag `dockerhub-<version>`
4. Pushes commits and tags

### Prerequisites
- Logged into DockerHub (`docker login`)
- Docker Buildx configured

## Version Management

The Haven version is pinned in `Dockerfile`:

```dockerfile
ARG TAG=v1.2.0-rc2
ARG COMMIT=986c21b79c93779a449a52f6414ea267c83428bb
```

The release script extracts the version with:
```bash
VERSION=`awk -F "=" '/TAG=/{print $NF}' Dockerfile`
```

**To bump**: update `TAG` and `COMMIT` in `Dockerfile`, then run the release workflow.

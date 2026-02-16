---
description: Release a new Haven version to DockerHub and GHCR
---

## Steps

1. Check the latest Haven release at https://github.com/bitvora/haven/releases

2. Update the version in `Dockerfile`:
   ```
   ARG TAG=<new-version>
   ARG COMMIT=<new-commit-hash>
   ```

3. Test the build locally:
   // turbo
   ```bash
   docker compose build --no-cache
   ```

4. Verify the container starts:
   ```bash
   docker compose up -d
   docker logs -f haven
   ```

5. Push to DockerHub (requires `docker login`):
   ```bash
   make release
   ```

   This will also create a git tag `dockerhub-<version>` and push it.

6. The GitHub Actions workflow will automatically build and push to GHCR on the next push to `main`.

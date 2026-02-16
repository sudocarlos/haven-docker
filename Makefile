# haven-docker Makefile

USERNAME   := sudocarlos
IMAGE      := haven
VERSION    := $(shell awk -F '=' '/TAG=/{print $$NF}' Dockerfile)

.PHONY: build dev up down logs test release tag push clean

## Development ─────────────────────────────────────────────

build:  ## Build the image
	docker compose build

dev:  ## Build (no cache) and start with logs
	docker compose build --no-cache
	docker compose up -d
	docker compose logs -f

up:  ## Start the container
	docker compose up -d

down:  ## Stop the container
	docker compose down

logs:  ## Tail container logs
	docker compose logs -f

## Testing ─────────────────────────────────────────────────

test:  ## Run Docker image tests
	bash tests/test-image.sh

## Release ─────────────────────────────────────────────────

release: push tag  ## Build, push to DockerHub, and git-tag

push:  ## Build and push to DockerHub
	@echo "Building version: $(VERSION)"
	docker buildx build --no-cache \
		-t $(USERNAME)/$(IMAGE):latest \
		-t $(USERNAME)/$(IMAGE):$(VERSION) \
		--push .

tag:  ## Commit and git-tag the release
	git add -A
	git commit -m "haven-docker $(VERSION)"
	git tag -a "dockerhub-$(VERSION)" -m "haven-docker $(VERSION)"
	git push
	git push --tags

## Utility ─────────────────────────────────────────────────

clean:  ## Remove stopped containers and dangling images
	docker compose down --remove-orphans
	docker image prune -f

version:  ## Print the current Haven version
	@echo $(VERSION)

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

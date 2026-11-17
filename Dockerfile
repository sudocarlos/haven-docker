ARG TAG=chore/khatru-successor-bump
ARG COMMIT=4b8d38b2632171dfda1e3cb3935ea0fe29630ac3

FROM golang AS builder

# Re-declare the pre-FROM ARGs: ARGs declared before the first FROM are not
# visible inside build stages, so without these two lines $TAG/$COMMIT expand
# to empty and `git checkout $COMMIT` silently no-ops onto the fork's default
# branch instead of the pinned commit.
ARG TAG
ARG COMMIT

RUN git clone https://github.com/sudoagent1/haven.git && \
  cd haven && \
  git fetch origin $TAG && \
  git checkout $COMMIT && \
  go install -v

FROM debian:stable-slim

SHELL ["/bin/bash", "-c"]
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gpg \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
		apt-transport-https; \
	mkdir /haven; \
	curl -fsSL https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | \
		gpg --dearmor -o /usr/share/keyrings/deb.torproject.org-keyring.gpg; \
	printf 'Types: deb\nURIs: https://deb.torproject.org/torproject.org\nSuites: bookworm\nComponents: main\nSigned-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg\n' | \
		tee /etc/apt/sources.list.d/deb.torproject.org.sources > /dev/null; \
	apt-get install -y --no-install-recommends tor

COPY --from=builder /go/haven /haven
COPY --from=builder /go/bin/haven /haven/haven
COPY ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]
EXPOSE 3355

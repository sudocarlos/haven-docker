ARG TAG=v1.2.0-rc6
ARG COMMIT=5c645530ac085dd78fb0d1b24f873c1efa8f4430

FROM golang AS builder

RUN git clone https://github.com/bitvora/haven.git && \
  cd haven && \
  git checkout $TAG && \
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
	echo $'Types: deb \n\
URIs: https://deb.torproject.org/torproject.org \n\
Suites: bookworm \n\
Components: main \n\
Signed-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg' | \
		tee /etc/apt/sources.list.d/deb.torproject.org.sources > /dev/null; \
	apt-get install -y --no-install-recommends tor

COPY --from=builder /go/haven /haven
COPY --from=builder /go/bin/haven /haven/haven
COPY ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]
EXPOSE 3355

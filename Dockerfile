FROM golang AS builder

ARG TAG=v1.0.5.1

RUN git clone https://github.com/bitvora/haven.git && \
  git clone https://github.com/fiatjaf/khatru.git && \
  cd haven && \
  go mod edit -replace github.com/fiatjaf/khatru=../khatru && \
  go install -v
 
# From docker-library/golang/1.23/bookworm/Dockerfile
# install cgo-related dependencies
FROM buildpack-deps:bookworm-scm

SHELL ["/bin/bash", "-c"]
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
		curl \
		gpg \
		apt-transport-https; \
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
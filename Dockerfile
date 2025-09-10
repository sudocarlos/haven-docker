ARG TAG=v1.1.0.1
ARG COMMIT=cb9daef00c6b3498642b84c8e7ce0993e5d5ad6c

FROM debian:stable-slim

SHELL ["/bin/bash", "-c"]
RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		curl \
		gpg \
		apt-transport-https; \
	curl -sSL -O https://github.com/bitvora/haven/releases/download/v1.1.0/haven_Linux_x86_64.tar.gz; \
	mkdir /haven; \
	tar -xvf haven_Linux_x86_64.tar.gz -C haven; \
	rm -rf haven_Linux_x86_64.tar.gz; \
	curl -fsSL https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | \
		gpg --dearmor -o /usr/share/keyrings/deb.torproject.org-keyring.gpg; \
	echo $'Types: deb \n\
URIs: https://deb.torproject.org/torproject.org \n\
Suites: bookworm \n\
Components: main \n\
Signed-By: /usr/share/keyrings/deb.torproject.org-keyring.gpg' | \
		tee /etc/apt/sources.list.d/deb.torproject.org.sources > /dev/null; \
	apt-get install -y --no-install-recommends tor

COPY ./start.sh /start.sh

ENTRYPOINT ["/start.sh"]
EXPOSE 3355

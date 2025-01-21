FROM golang AS builder

ARG TAG=master

RUN git clone https://github.com/bitvora/haven.git && \
  cd haven && \
  git checkout $TAG && \
  go install -v

 
# From docker-library/golang/1.23/bookworm/Dockerfile
# install cgo-related dependencies
FROM buildpack-deps:bookworm-scm

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config

COPY --from=builder /go/haven /haven
COPY --from=builder /go/bin/haven /haven/haven

WORKDIR /haven
ENTRYPOINT ["./haven"]
EXPOSE 3355
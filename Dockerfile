FROM golang AS builder

ARG TAG=master

RUN git clone https://github.com/bitvora/haven.git && \
  cd haven && \
  git checkout $TAG && \
  go install

FROM fedora

COPY --from=builder /go/haven /haven
COPY --from=builder /go/bin/haven /haven/haven

WORKDIR /haven
CMD ["./haven"]
EXPOSE 3355
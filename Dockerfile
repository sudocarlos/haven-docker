FROM golang AS build

WORKDIR /
RUN git clone https://github.com/bitvora/haven.git
WORKDIR /haven
RUN go build

FROM debian
COPY --from=build /go/haven /haven
WORKDIR /haven
CMD ["/haven/haven"]
EXPOSE 3355
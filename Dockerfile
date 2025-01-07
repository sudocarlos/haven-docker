FROM golang AS build
RUN git clone https://github.com/bitvora/haven.git && cd haven && go build

FROM debian
COPY --from=build /go/haven/haven /haven/app
CMD ["/haven/app"]
EXPOSE 3355
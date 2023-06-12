FROM golang:latest as build
WORKDIR /go/src/github.com/pomerium/pomerium

RUN apt-get update \
    && apt-get -y install zip

# cache depedency downloads
COPY go.mod go.sum ./
RUN go mod download
COPY . .

# build
RUN make build-deps
RUN touch /config.yaml

FROM gcr.io/distroless/base:debug
ENV AUTOCERT_DIR /data/autocert
WORKDIR /pomerium
COPY --from=build /config.yaml /pomerium/config.yaml
ENTRYPOINT [ "/bin/pomerium" ]
CMD ["-config","/pomerium/config.yaml"]

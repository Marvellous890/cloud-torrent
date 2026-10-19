FROM golang:1.25-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
ARG VERSION=0.0.0-docker
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w -X main.version=${VERSION}" -o /cloud-torrent .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=build /cloud-torrent /usr/local/bin/cloud-torrent
# downloads default to ./downloads, so running from / keeps the /downloads volume from the README working
WORKDIR /
VOLUME /downloads
# 3000: web UI, 50007: torrent incoming port (tcp+udp)
EXPOSE 3000 50007 50007/udp
ENTRYPOINT ["cloud-torrent"]

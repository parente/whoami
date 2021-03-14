# Let buildx specify the build platform image
FROM --platform=$BUILDPLATFORM golang:alpine AS builder

RUN apk --no-cache --no-progress add git ca-certificates tzdata make \
    && update-ca-certificates \
    && rm -rf /var/cache/apk/*

WORKDIR /go/whoami

# Download go modules
COPY go.mod .
COPY go.sum .
RUN GO111MODULE=on GOPROXY=https://proxy.golang.org go mod download

COPY . .

# Let buildx specify the target platform
ARG TARGETARCH
ARG TARGETOS

# Pass the target platform through to the go compiler/linker
RUN GOOS=${TARGETOS} GOARCH=${TARGETARCH} make build

# Create a minimal container to run a Golang static binary
FROM scratch

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /go/whoami/whoami .

ENTRYPOINT ["/whoami"]
EXPOSE 80

# required for single platform build in a Github action, otherwise not necessary:
ARG BUILDPLATFORM=linux/amd64
FROM --platform=$BUILDPLATFORM golang:1.19 AS builder
ARG TARGETOS TARGETARCH

WORKDIR /app
COPY go.mod ./
COPY main.go ./
RUN go mod download
RUN GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 go build -o /helloserver main.go

# Create a new release build stage
FROM gcr.io/distroless/base-debian10

# Set the working directory to the root directory path
WORKDIR /
# Copy over the binary built from the previous stage
COPY --from=builder /helloserver /helloserver

ENTRYPOINT ["/helloserver"]
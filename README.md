# simpleserver
A minimalistic web server written in Go as example for Open Component Model

# Requirements
This example uses the tooling of the [Open Component Model](https://ocm.software). Dowload and install
the latest release from the [Git Repository](https://github.com/open-component-model/ocm/releases).

# Example creating a multi-arch component version
See the [Getting Started Guide](https://github.com/open-component-model/ocm-spec/blob/getting-started/doc/scenarios/getting-started/README.md) for instructions.

```shell
# Build 64-bit images for ARM and Intel platforms

TAG_PREFIX=eu.gcr.io/my-project/acme # path to you OCI registry --> change to your environment
PLATFORM=linux/amd64
VERSION=0.1.0

docker buildx build --load -t ${TAG_PREFIX}/simpleserver:0.1.0-linux-amd64 --platform linux/amd64 .

docker buildx build --load -t ${TAG_PREFIX}/simpleserver:0.1.0-linux-arm64 --platform linux/arm64 .

# Check the built images
docker image ls

# Create a component archive
PROVIDER=acme
COMPONENT=github.com/{PROVIDER}/simpleserver
VERSION=0.1.0
mkdir gen
ocm create ca ${COMPONENT} ${VERSION} --provider ${PROVIDER} --file gen/ca

# Add resources to the component archive
ocm add resources ./gen/ca resources.yaml

# Push to an OCI registry
OCMREPO=ghcr.io/${PROVIDER}
ocm transfer ca gen/ca $OCMREPO

# Create a transport archive
ocm transfer ca gen/ca gen/ctf
```

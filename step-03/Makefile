# SPDX-FileCopyrightText: 2022-2023 SAP SE or an SAP affiliate company and Open Component Model contributors.
#
# SPDX-License-Identifier: Apache-2.0
NAME      ?= simpleserver
PROVIDER  ?= acme.org
GITHUBORG ?= acme
IMAGE     = ghcr.io/$(GITHUBORG)/$(NAME)
COMPONENT = $(PROVIDER)/$(NAME)
OCMREPO   ?= ghcr.io/$(GITHUBORG)/ocm
MULTI     ?= true
PLATFORMS ?= linux/amd64 linux/arm64
REPO_ROOT           = .
VERSION             ?= $(shell git describe --tags --exact-match 2>/dev/null|| echo "$$(cat $(REPO_ROOT)/VERSION)")
COMMIT              = $(shell git rev-parse HEAD)
EFFECTIVE_VERSION   = $(VERSION)-$(COMMIT)
GIT_TREE_STATE      := $(shell [ -z "$(git status --porcelain 2>/dev/null)" ] && echo clean || echo dirty)
GEN = ./gen
OCM = ocm

CHART_SRCS=$(shell find helmchart -type f)
GO_SRCS=$(shell find . -name \*.go -type f)

ifeq ($(MULTI),true)
FLAGSUF     = .multi
endif

.PHONY: build
build: $(GEN)/build

.PHONY: version
version:
	@echo $(VERSION)

.PHONY: ca
ca: $(GEN)/ca

$(GEN)/ca: $(GEN)/.exists $(GEN)/image.$(NAME)$(FLAGSUF) resources.yaml $(CHART_SRCS)
	$(OCM) create ca -f $(COMPONENT) "$(VERSION)" --provider $(PROVIDER) --file $(GEN)/ca
	$(OCM) add resources --templater spiff $(GEN)/ca COMMIT="$(COMMIT)" VERSION="$(VERSION)" \
		IMAGE="$(IMAGE):$(VERSION)" PLATFORMS="$(PLATFORMS)" MULTI=$(MULTI) resources.yaml
	@touch $(GEN)/ca

$(GEN)/build: $(GO_SRCS)
	go build .
	@touch $(GEN)/build

.PHONY: image
image: $(GEN)/image.$(NAME)

$(GEN)/image.$(NAME): $(GEN)/.exists Dockerfile $(OCMSRCS)
	docker build -t $(IMAGE):$(VERSION) --file Dockerfile $(COMPONENT_ROOT) .;
	@touch $(GEN)/image.$(NAME)

.PHONY: multi
multi: $(GEN)/image.$(NAME).multi

$(GEN)/image.$(NAME).multi: $(GEN)/.exists Dockerfile $(GO_SRCS)
	echo "Building Multi $(PLATFORMS)"
	for i in $(PLATFORMS); do \
	tag=$$(echo $$i | sed -e s:/:-:g); \
	echo "Building platform $$i with tag: $$tag for version ${VERSION}"; \
	docker buildx build --load -t $(IMAGE):$(VERSION)-$$tag --platform $$i .; \
	done
	@touch $(GEN)/image.$(NAME).multi

.PHONY: ctf
ctf: $(GEN)/ctf

$(GEN)/ctf: $(GEN)/ca
	@rm -rf $(GEN)/ctf
	$(OCM) transfer ca $(GEN)/ca $(GEN)/ctf
	touch $(GEN)/ctf

.PHONY: push
push: $(GEN)/ctf $(GEN)/push.$(NAME)

$(GEN)/push.$(NAME): $(GEN)/ctf
	$(OCM) transfer ctf -f $(GEN)/ctf $(OCMREPO)
	@touch $(GEN)/push.$(NAME)

.PHONY: transport
transport:
ifneq ($(TARGETREPO),)
	$(OCM) transfer component -Vc  $(OCMREPO)//$(COMPONENT):$(VERSION) $(TARGETREPO)
else
	@echo "Cannot transport no TARGETREPO defined as destination" && exit 1
endif

$(GEN)/.exists:
	@mkdir -p $(GEN)
	@touch $@

.PHONY: info
info:
	@echo "VERSION:  $(VERSION)"
	@echo "COMMIT:   $(COMMIT)"
	@echo "TREESTATE:   $(GIT_TREE_STATE)"

.PHONY: describe
describe: $(GEN)/ctf
	ocm get resources --lookup $(OCMREPO) -r -o treewide $(GEN)/ctf

.PHONY: descriptor
descriptor: $(GEN)/ctf
	ocm get component -S v3alpha1 -o yaml $(GEN)/ctf

.PHONY: clean
clean:
	rm -rf $(GEN)

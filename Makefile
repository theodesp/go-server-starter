GO ?= go
GOFMT ?= gofmt "-s"
GOFILES := $(shell find . -name "*.go" -type f -not -path "./vendor/*")
PACKAGES ?= $(shell $(GO) list ./... | grep -v /vendor/)
IMAGE := theodesp/go-requestbin

VERSION := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
VCS_URL := $(shell git config --get remote.origin.url)
VCS_REF := $(shell git rev-parse HEAD)
NAME := $(shell basename `git rev-parse --show-toplevel`)
VENDOR := $(shell whoami)

print:
	@echo VERSION=${VERSION} 
	@echo BUILD_DATE=${BUILD_DATE}
	@echo VCS_URL=${VCS_URL}
	@echo VCS_REF=${VCS_REF}
	@echo NAME=${NAME}
	@echo VENDOR=${VENDOR}

all: test-all

test-all: test-lint test

.PHONY: test
test:
	-rm -f coverage.out
	@for package in $(PACKAGES) ; do \
		$(GO) test -race -coverprofile=profile.out -covermode=atomic $$package ; \
		if [ -f profile.out ]; then \
			cat profile.out | grep -v "mode:" >> coverage.out; \
			rm profile.out ; \
		fi \
	done

.PHONY: test-lint
test-lint:
	golangci-lint run $(GOFILES)

vet:
	$(GO) vet $(PACKAGES)

# Test fast
test-fast:
	$(GO) test -short ./...

.PHONY: fmt
fmt:
	$(GOFMT) -w $(GOFILES)

# Clean junk
.PHONY: clean
clean:
	$(GO) clean ./...

.PHONY: install
install:
	$(GO) get -u github.com/stretchr/testify

.PHONY: image
image:
	@if [ "${DEPLOY}" = "true" ]; then\
		docker build --pull --cache-from "${IMAGE}" \
		--build-arg VERSION="${VERSION}" \
		--build-arg BUILD_DATE="${BUILD_DATE}" \
		--build-arg VCS_URL="${VCS_URL}" \
		--build-arg VCS_REF="${VCS_REF}" \
		--build-arg NAME="${NAME}" \
		--build-arg VENDOR="${VENDOR}" \
		--tag "${IMAGE}" .;\
	fi

.PHONY: push-image
push-image:
	docker tag "${IMAGE}" "${IMAGE}:latest"
	docker tag "${IMAGE}" "${IMAGE}:${VERSION}"
	docker push ${IMAGE}:${VERSION}
	docker push ${IMAGE}:latest

.PHONY: run
run:
	@docker run theodesp/go-requestbin

.PHONY: label
label:
	@docker inspect --format='{{json .Config.Labels}}' theodesp/go-requestbin
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

build:
	docker build \
	--build-arg VERSION="${VERSION}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--build-arg VCS_URL="${VCS_URL}" \
	--build-arg VCS_REF="${VCS_REF}" \
	--build-arg NAME="${NAME}" \
	--build-arg VENDOR="${VENDOR}" \
	-t theodesp/go-requestbin .

run:
	@docker run theodesp/go-requestbin

label:
	@docker inspect --format='{{json .Config.Labels}}' theodesp/go-requestbin
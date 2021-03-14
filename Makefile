.PHONY: builder local-image all-images

TAG_NAME := $(shell git tag -l --contains HEAD)
NAME := whoami
IMAGE_NAME := parente/$(NAME)

# Expose build platform args from the environment
export GOOS?=
export GOARCH?=

build:
	CGO_ENABLED=0 go build -a --trimpath --installsuffix cgo --ldflags="-s" -o $(NAME)

builder:
	docker buildx create \
		--name $(NAME) \
		--driver docker-container

local-image:
	DOCKER_BUILDKIT=1 docker buildx build \
		--builder $(NAME) \
		--load \
		--tag $(NAME):latest .

push-images:
	DOCKER_BUILDKIT=1 docker buildx build \
		--builder $(NAME) \
		--push \
		--tag $(IMAGE_NAME):latest .

#REGISTRY ?= ensl
PROJECT  ?= ensl-plugin
TAG      ?= latest

ifdef REGISTRY
  IMAGE=$(REGISTRY)/$(PROJECT):$(TAG)
else
  IMAGE=$(PROJECT)
endif

all:
	@echo "Available targets:"
	@echo "  * build - build a Docker image for $(IMAGE)"
	@echo "  * pull  - pull $(IMAGE)"
	@echo "  * push  - push $(IMAGE)"
	@echo "  * test  - build and test $(IMAGE)"

build: Dockerfile
	docker build . -t $(IMAGE)

run: build
	docker run -v $(shell pwd)/build/:/var/build -ti $(IMAGE)

pull:
	docker pull $(IMAGE) || true

push:
	docker push $(IMAGE)

clean:
	rm -rf $(shell pwd)/build/*

test: build
	@echo "TODO"

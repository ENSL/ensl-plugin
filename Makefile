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
	docker ps -a | awk '{ print $$1,$$2 }' | grep $(IMAGE) |awk '{print $$1 }' |xargs -I {} docker rm {}
	docker images -a |grep $(IMAGE) |awk '{print $$3}' |xargs -I {} docker rmi {}

test: build
	@echo "TODO"

REPO ?= 634084408939.dkr.ecr.us-west-1.amazonaws.com
IMAGE ?= example
VERSION ?= $(shell git rev-parse --short HEAD)

.PHONY: dev
dev: docker
	@echo "Running dev container"
	docker-compose -f ./docker/docker-compose.yml run --rm -p 3000:3000 -p 35729:35729 dev

.PHONY: test
test: docker
	@echo "Running test container"
	docker-compose -f ./docker/docker-compose.yml run --rm test

.PHONY: deploy
deploy: docker
	@echo "Deploying project"
	docker-compose -f ./docker/docker-compose.yml run --rm ensure-repo
	docker build . -t $(REPO)/$(IMAGE):$(VERSION)
	$$(aws ecr get-login --no-include-email --region us-west-1)
	docker push $(REPO)/$(IMAGE):$(VERSION)
	docker-compose -f ./docker/docker-compose.yml run --rm deploy

.PHONY: clean
clean:
	@echo "Ensuring docker containers are cleaned up"
	docker-compose -f ./docker/docker-compose.yml down --remove-orphans

.PHONY: docker
docker:
	@echo "Ensuring docker containers are up-to-date"
	docker-compose -f ./docker/docker-compose.yml build

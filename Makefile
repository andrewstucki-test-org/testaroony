IMAGE ?= example

REPO ?= 634084408939.dkr.ecr.us-east-1.amazonaws.com
VERSION ?= $(shell git rev-parse --short HEAD)

DOCKER_COMPOSE ?= docker-compose -f ./docker/docker-compose.yml
DOCKER_COMPOSE_RUN ?= $(DOCKER_COMPOSE) run --rm
DOCKER_COMPOSE_DOWN ?= $(DOCKER_COMPOSE) down --remove-orphans
DOCKER_COMPOSE_BUILD ?= $(DOCKER_COMPOSE) build

IMAGE_TAG := $(REPO)/$(IMAGE):$(VERSION)

.PHONY: dev
dev: docker
	@echo "Running dev container"
	$(DOCKER_COMPOSE_RUN) -p 3000:3000 -p 35729:35729 dev

.PHONY: test
test: docker
	@echo "Running test container"
	$(DOCKER_COMPOSE_RUN) test

.PHONY: deploy
deploy: docker
	@echo "Deploying project"
	@$(DOCKER_COMPOSE_RUN) terraform "terraform init && terraform apply -auto-approve -target aws_ecr_repository.repo -var image=$(IMAGE_TAG)"
	@docker build . -t $(IMAGE_TAG)
	@$$(aws ecr get-login --no-include-email --region us-west-1)
	@docker push $(IMAGE_TAG)
	@$(DOCKER_COMPOSE_RUN) terraform "terraform init && terraform apply -auto-approve -var image=$(IMAGE_TAG)"
	@$(DOCKER_COMPOSE_RUN) terraform "terraform init && wait-for-ecs \`terraform output cluster\` $(IMAGE)"

PHONY: encrypt
encrypt:
	@$(DOCKER_COMPOSE_RUN) -v $(PWD):/src terraform encrypt

PHONY: decrypt
decrypt:
	@$(DOCKER_COMPOSE_RUN) -v $(PWD):/src terraform decrypt

.PHONY: clean
clean:
	@echo "Ensuring docker containers are cleaned up"
	$(DOCKER_COMPOSE_DOWN)

.PHONY: docker
docker:
	@echo "Ensuring docker containers are up-to-date"
	$(DOCKER_COMPOSE_BUILD)

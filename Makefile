.PHONY: default
default: docker
	@echo "Running dev container"
	@docker-compose -f ./docker/docker-compose.yml run --rm -p 3000:3000 -p 35729:35729 dev

.PHONY: test
test: docker
	@echo "Running test container"
	@docker-compose -f ./docker/docker-compose.yml run --rm test

.PHONY: docker
docker:
	@echo "Ensuring docker containers are up-to-date"
	@docker-compose -f ./docker/docker-compose.yml build > /dev/null 2>&1

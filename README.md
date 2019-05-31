# Example Buffalo Application

Most of these files were generated with the vanilla
[buffalo 0.14.3](https://github.com/gobuffalo/buffalo) generator. In the
works are a [yeoman](https://yeoman.io) generator to generate the build and
deployment-specific pieces of the buffalo project--because, frankly, it's not
super friendly to running as a 12-factor app by default.

## Components

Here are the major components that differ from a vanilla project:

1. `database.yml` - This was re-written to use environment variables in both
development and testing.
2. `package.json` - Includes `jest` and some other frontend testing libraries.
3. `.dockerignore` - Standard [.dockerignore](https://docs.docker.com/engine/reference/builder/#dockerignore-file)
file.
4. `Makefile` - A generic, reusable Makefile to handle the following primary
build targets:
	- `make dev` - Starts up a postgres container used by a buffalo docker
	container in development mode and ports forwarded for the go server and
	node webpack hot-reload server.
	- `make test` - Starts up a postgres container and runs unit tests against it.
	- `make deploy` - Builds a docker container and runs [terraform](https://terraform.io)
	with a lifecycle described below.
	- `make clean` - Makes sure all containers referenced in `./docker/docker-compose.yml`
	are stopped and removed.
5. `Jenkinsfile` - Runs `make test`, `make deploy`, and ensures `make clean` has been
run on Jenkins.
6. `deployment.tf` - Holds the `terraform` manifest for deployment to AWS ECS.
7. `docker` directory - Docker files for development and deployment.
	- `docker/docker-compose.yml` - handles the interdependencies for the buffalo
	project as well as caching mounts for build speed-up and environment variable
	forwarding.
	- `docker/Dockerfile.deploy` - `terraform` container with access to the `deployment.tf`
	file.
	- `docker/Dockerfile.deploy` - `buffalo` container with go module and node module
	caching.
8. `Dockerfile` - production container with auto-migrations.
9. `actions/cookies.go` - A wrapper to the cookie store so we actually store secure cookies.

## Terraform

This uses a terraform module for deploying ECS containers to an ECS cluster. Due
to the module both creating a private ECR repo as well deploying containers from it,
the following is the lifecycle for deploying an application:

1. Ensure that the ECR repo is created.
2. Build the docker container locally, tagged with the git sha of the application
code.
3. Log in to the ECR repo.
4. Push the container to the ECR repo.
5. Run the terraform deployment referencing the new container.

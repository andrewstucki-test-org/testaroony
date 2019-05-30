variable "image" {
  description = "Docker image to deploy"
}

terraform {
  required_version = "= 0.12.0"
  backend "s3" {
    bucket         = "lambda-coffee-testing" # "gp-apps-terraform-state"
    key            = "apps/example.tfstate"
    encrypt        = true
    dynamodb_table = "lambda-coffee-testing" # "gp-apps-terraform-lock"
    region         = "us-east-1"
  }
}

provider "aws" {
  version = "2.12.0"
  region  = "us-east-1"
}

data "terraform_remote_state" "base" {
  backend = "s3"
  config = {
    bucket = "lambda-coffee-testing" # "gp-apps-terraform-state"
    key    = "apps/terraform-new.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ecr_repository" "repo" {
  name = "example"
}

module "example" {
  source = "../modules/service"

  name      = "example"
  subdomain = "example"
  image     = var.image
  port      = 8081
  secrets = [{
    name  = "DATABASE_URL"
    value = data.terraform_remote_state.base.outputs.rds
  }]
  health_check = {
    path    = "/"
    matcher = "200"
  }

  state = data.terraform_remote_state.base.outputs
}

output "cluster" {
  value = data.terraform_remote_state.base.outputs.cluster
}

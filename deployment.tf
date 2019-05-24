terraform {
  required_version = ">= 0.12"

  backend "s3" {
    bucket         = "lambda-coffee-terraform"
    key            = "example.tfstate"
    encrypt        = true
    dynamodb_table = "lambda-coffee-terraform"
    region         = "us-west-1"
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_ecr_repository" "repo" {
  name = "example"
}

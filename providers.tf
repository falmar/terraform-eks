provider "aws" {
  region = "eu-west-1"

  default_tags {}
}

data "aws_availability_zones" "available" {
  state = "available"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7"
}

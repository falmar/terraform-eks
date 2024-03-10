data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
    }
  }
}
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
provider "kubectl" {
  config_path = var.kubeconfig_path
}
provider "kustomization" {
  kubeconfig_path = var.kubeconfig_path
}

data "aws_availability_zones" "available" {
  state = "available"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubectl = {
     source  = "alekc/kubectl"
      version = "~> 2.0"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
  }
  required_version = ">= 1.7"
}

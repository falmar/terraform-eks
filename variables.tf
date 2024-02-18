locals {
  project_name  = "${var.project_name}-${var.environment}"
  project_name_ = replace(local.project_name, "-", "_")
}

variable "bootstrap" {
  type    = bool
  default = false
}
variable "critical_apps" {
  type    = number
  default = 0
}
variable "allow_nodes" {
  type = bool
  default = true
}

variable "aws_region" {
  description = "The AWS region in which the resources are created"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "lavieri"
}
variable "environment" {
  description = "The environment in which the resources are created"
  type        = string
  default     = "dev"
}

variable "kubeconfig_path" {
  type    = string
  default = "~/.kube/config"
}

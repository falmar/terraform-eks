variable "critical_apps" {
  type = bool
}

variable "k8s_service_endpoint" {
  type = string
}
variable "k8s_service_port" {
  type    = string
  default = "6443"
}
variable "public_nlb_security_group" {
  type = string
}

variable "project_name" {
  type = string
}

variable "account_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "oidc_provider_arn" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}

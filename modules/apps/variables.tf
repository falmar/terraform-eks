variable "bootstrap" {
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

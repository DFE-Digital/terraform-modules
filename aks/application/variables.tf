variable "name" {
  type = string
}

variable "namespace" {
  type        = string
  description = "Current namespace"
}

variable "app_environment" {
  type    = string
  default = "Current application environment"
}

variable "resource_group_name" {
  type = string
}

variable "cluster_configuration_map" {
  type = object({
    resource_group_name = string,
    resource_prefix     = string,
    dns_zone_prefix     = optional(string),
    cpu_min             = number
  })
}

variable "replicas" {
  type    = number
  default = 1
}

variable "kubernetes_config_map_name" {
  type = string
}

variable "kubernetes_secret_name" {
  type = string
}

variable "docker_image" {
  type = string
}

variable "command" {
  type = list(string)
}

variable "external_hostnames" {
  type = list(string)
}

variable "max_memory" {
  type = number
}

variable "is_web" {
  type    = bool
  default = true
}

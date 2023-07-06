variable "name" {
  type        = string
  description = "Name of the application"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Current namespace"
}

variable "environment" {
  type        = string
  description = "Current application environment"
}

variable "service_name" {
  type        = string
  description = "Name of the service"
}

variable "cluster_configuration_map" {
  type = object({
    resource_group_name = string,
    resource_prefix     = string,
    dns_zone_prefix     = optional(string),
    cpu_min             = number
  })
  description = "Configuration map for the cluster"
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Number of application instances"
}

variable "kubernetes_config_map_name" {
  type        = string
  description = "Name of the Kubernetes configuration map"
}

variable "kubernetes_secret_name" {
  type        = string
  description = "Name of the Kubernetes secrets"
}

variable "docker_image" {
  type        = string
  description = "Path to the docker image"
}

variable "command" {
  type        = list(string)
  default     = []
  description = "Custom command that overwrites Docker image"
}

variable "max_memory" {
  type        = string
  default     = "1Gi"
  description = "Maximum memory of the instance"
}

variable "is_web" {
  type        = bool
  default     = true
  description = "Whether this a web application"
}

variable "web_external_hostnames" {
  type        = list(string)
  default     = []
  description = "List of external hostnames for the web application"
}

variable "web_port" {
  type        = number
  default     = 3000
  description = "Port of the web application"
}

variable "probe_path" {
  type        = string
  default     = "/healthcheck"
  description = "Path for the liveness and startup probe. The probe can be disabled by setting this to null."
}

variable "probe_command" {
  type        = list(string)
  default     = []
  description = "Command for the liveness and startup probe"
}


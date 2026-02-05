variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "service_name" {
  description = "Name of the service. Usually the same as the repo name"
}
variable "docker_image" {
  description = "Docker image to be used for this job"
}
variable "environment" {
  description = "Environment where this app is deployed. Usually test or production"
}
#'NEW VARIABLES - NEED TO CONSUME OUTPUT VARIABLES FROM application_configuration module
variable "config_map_ref" {
  description = "formerly: module.application_configuration.kubernetes_config_map_name"
  type        = string
}
variable "secret_ref" {
  description = "formerly: module.application_configuration.kubernetes_secret_name"
  type        = string
}

variable "cpu" {
  description = "formerly: module.cluster_data.configuration_map.cpu_min"
  type        = string
}

variable "commands" {
  description = "list of required docker image commands for k8s job to run"
  type        = list(string)
  # default to a rails db prepare - https://guides.rubyonrails.org/active_record_migrations.html#preparing-the-database
  default = ["bundle"]
}

variable "arguments" {
  description = "list of required docker image arguments for k8s job to run"
  type        = list(string)
  # default to a rails db prepare - https://guides.rubyonrails.org/active_record_migrations.html#preparing-the-database
  default = ["name", "mount_path", ""]
}

variable "job_name" {
  description = "name handle for k8s job"
  type        = string
  default     = "migration"
}

variable "enable_logit" {
  description = "boolean for enabling Logit"
  type        = string
  default     = "false"
}

variable "max_memory" {
  type        = string
  nullable    = false
  default     = "1Gi"
  description = "Maximum memory of the instance"
}

variable "enable_gcp_wif" {
  type        = string
  default     = false
  description = "Let the job use the GCP workload identity federation service account to get a token"
  nullable    = false
}

variable "schedule" {
  type        = string
  default     = "1 0 * * *"
  description = "job run schedule using cron syntax"
  nullable    = false
}

variable "config_map_name" {
  type        = string
  description = "Name of the Kubernetes configuration map"
}

variable "cm_mount" {
  description = "config map to be mounted in terraform"
  type        = list(string)
  default     = [ "" ]
#  default = ["name", "mountpoint", "configmap"]
}

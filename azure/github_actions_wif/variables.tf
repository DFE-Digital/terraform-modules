variable "resource_group_name" {
  type        = string
  default     = null
  description = "The name of the resource group where the resources will be created. Use this variable to override the default resource group name generated from subscription_short and subscription_env."
}

variable "subscription_short" {
  type        = string
  description = "The prefix for the subscription. e.g. s158, s115 etc"
}

variable "env_short" {
  type        = string
  description = "The environment for the subscription. e.g. d01, t01, p01 etc"
}

variable "service_short" {
  type        = string
  description = "The short name for the service."
}

variable "config_short" {
  type        = string
  description = "The short name for the environment. e.g. dv, ts, pd etc"
}

variable "environment" {
  type        = string
  description = "The environment for the resources. e.g. development, test, production etc"
}

variable "ga_wif_managed_id" {
  type        = map(map(list(string)))
  default     = {}
  description = "A map of maps of lists containing the GitHub Actions Workload Identity Federation (WIF) managed identities. The outer map's keys are the group names, the inner map's keys are the repository names, and the inner map's values are lists of environment names."
}

variable "ga_wif_immutable_repos" {
  type        = map(any)
  description = <<-EOT
    Map of repos that are using immutable subject claims for WIF, with each repo mapped to its repo ID. Example:
    {
      repo_name_1 = {
        repo_id = "123451"
      }
      repo_name_2 = {
        repo_id = "123452"
      }
    }
  EOT
  default     = {}
}

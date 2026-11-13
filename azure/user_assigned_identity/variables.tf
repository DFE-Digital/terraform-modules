# Service variables
variable "subscription_short" {
  type        = string
  description = "The short name of the subscription e.g. s189"
}

variable "env_short" {
  type        = string
  description = "The short name of the environment e.g. d01, t01, p01"
}

variable "service_short" {
  type        = string
  description = "The short name of the service e.g. gias"
}

variable "service_name" {
  type        = string
  description = "The full name of the service e.g. get-information-about-schools"
}

variable "environment" {
  type        = string
  description = "The full name of the application service environment e.g. development, test, production"
}

variable "config_short" {
  type        = string
  description = "The short name of the environment configuration e.g. dv, ts, pd"
}

variable "user_assigned_identity_short" {
  type        = string
  description = "A short name that will be used in the user assigned identity name e.g. crm = s189d01-crm-dev-crm-id"
}
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

variable "service_bus_sku" {
  type        = string
  description = "The SKU of the Service Bus namespace. Valid values are: Basic, Standard, Premium"
  default     = "Standard"
}

variable "subnet_id" {
  type        = string
  description = "The id of the subnet which will be used by this Service Bus namespace"
}

variable "dnszone_name" {  
}

variable "dnszone_id" {  
}

variable "service_bus_name" {
  type        = string
  description = "The name of the Service Bus namespace that gets added as a suffix to the standard resource name."
  default     = null
}

variable "servicebus_queues" {
  type = map(object({
    requires_session                        = optional(bool, true)
    requires_duplicate_detection            = optional(bool, true)
    duplicate_detection_history_time_window = optional(string, "10 minutes")
    max_delivery_count                      = optional(number, 10)
    dead_lettering_on_message_expiration    = optional(bool, true)
    default_message_ttl                     = optional(string, "1 hour")
    lock_duration                           = optional(string, "1 minute")
    batched_operations_enabled              = optional(bool, true)
    write_queue_duplicate_detection_window  = optional(string, "10 minutes")
    write_queue_max_delivery_count          = optional(number, 10)
    write_queue_message_ttl                 = optional(string, "1 hour")
    write_queue_lock_duration               = optional(string, "1 minute")
  }))
  description = "A map of Service Bus queue configurations for the Service Bus namespace"
}


variable "hosted_zone" {
  type        = map(any)
  default     = {}
  description = "List of zones and their properties. See [README](readme.md) for details."
}

variable "tags" {
  default     = null
  description = "Azure resource tags. Deprecated: set tags at resource group level"
}

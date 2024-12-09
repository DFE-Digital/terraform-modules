variable "hosted_zone" {
  type        = map(any)
  default     = {}
  description = "List of zones and the records to create for each one. See [README](readme.md) for details."
}

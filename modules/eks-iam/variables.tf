variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "cluster_service_ipv4_cidr" {
  description = "The CIDR block for the Kubernetes service network"
  type        = string
  default     = "172.20.0.0/16"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
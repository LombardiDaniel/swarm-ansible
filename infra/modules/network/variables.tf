variable "project_name" {
  type = string
}

variable "allowed_udp_ports" {
  type        = list(number)
  default     = []
  description = "on managers"
}

variable "allowed_tcp_ports" {
  type        = list(number)
  default     = []
  description = "on managers"
}

variable "api_key" {
  type        = string
  description = "MGC_API_KEY"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "[OPTIONAL] VPC ID, if none is passed, will create a new one"
}

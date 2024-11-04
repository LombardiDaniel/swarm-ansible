variable "project_name" {
  type = string
}

variable "allow_ssh" {
  type    = bool
  default = true
}

variable "allowed_udp_ports" {
  type    = list(number)
  default = []
}

variable "allowed_tcp_ports" {
  type    = list(number)
  default = []
}
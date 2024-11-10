variable "project_name" {
  type        = string
  description = "project name, used on naming of resources"
}

variable "run_ansible" {
  description = "Runs Ansible Scripts after creating infra, may cause errors because DNS will not be available for LetsEncrypt"
  type        = bool
  default     = false
}

variable "ssh_key_name" {
  type        = string
  description = "SSH key name in MGC"
}

variable "machine_type" {
  type    = string
  default = "BV1-1-10"
}

variable "cluster_size" {
  type    = number
  default = 3
}

variable "hosts_ini_path" {
  type    = string
  default = "../hosts/hosts.ini"
}

variable "api_key" {
  type        = string
  description = "MGC_API_KEY"
}


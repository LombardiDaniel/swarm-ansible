variable "project_name" {
  type    = string
  default = "my_project_name"
}

variable "ssh_key_name" {
  type    = string
  default = "my_ssh_key_name"  # ssh key name in mgc (check out the CLI)
}

variable "machine_type" {
  type    = string
  default = "BV1-1-10"
}

variable "cluster_size" {
  type    = number
  default = 3
}

variable "manager_sec_group_ids" {
  type = list(string)
  default = [
    " 2de3d4e1-2f92-4321-9ee7-c6c49d0faef8"
  ]
}

variable "worker_sec_group_ids" {
  type = list(string)
  default = [
    " 2de3d4e1-2f92-4321-9ee7-c6c49d0faef8"  # can be the same as the manager sec group
  ]
}

variable "hosts_ini_path" {
  type    = string
  default = "../hosts/hosts.ini"
}
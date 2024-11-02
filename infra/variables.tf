variable "project_name" {
  type    = string
  default = "my_project_name"
}

variable "ssh_key_name" {
  type    = string
  default = "my_ssh_key_name"
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
    # "6f8d2314-59df-4d8f-b1b0-8215c9542a6a"
    " 2de3d4e1-2f92-4321-9ee7-c6c49d0faef8"
  ]
}

variable "worker_sec_group_ids" {
  type = list(string)
  default = [
    # "6f8d2314-59df-4d8f-b1b0-8215c9542a6a"
    " 2de3d4e1-2f92-4321-9ee7-c6c49d0faef8"
  ]
}

variable "hosts_ini_path" {
  type    = string
  default = "../hosts/hosts.ini"
}
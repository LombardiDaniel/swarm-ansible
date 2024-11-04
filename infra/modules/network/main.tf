terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.27.1"
    }
  }
}

provider "mgc" {
  alias  = "sudeste"
  region = "br-se1"
}

# https://www.youtube.com/watch?v=nMVXs8VnrF4
# https://www.youtube.com/watch?v=OeL2AlsdNaQ
resource "mgc_network_vpc" "swarm_vpc" {
  provider    = mgc.sudeste
  name        = "${var.project_name}-swarm-vpc"
  description = "${var.project_name}-swarm-vpc"
}

# resource "mgc_network_security_groups" "swarm_managers_sec_group" {
#   provider = mgc.sudeste
#   name     = "${var.project_name}-swarm-managers-sec-group"
# }
# resource "mgc_network_security_groups" "swarm_workers_sec_group" {
#   provider = mgc.sudeste
#   name     = "${var.project_name}-swarm-workers-sec-group"
# }

# resource "mgc_network_security_groups_rules" "allow_ssh_on_managers" {
#   count             = var.allow_ssh ? 1 : 0
#   description       = "Allow incoming SSH traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 22
#   port_range_min    = 22
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = mgc_network_security_groups.swarm_managers_sec_group.security_group_id
# }

# resource "mgc_network_security_groups_rules" "allow_ssh_on_workers" {
#   count             = var.allow_ssh ? 1 : 0
#   description       = "Allow incoming SSH traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 22
#   port_range_min    = 22
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = mgc_network_security_groups.swarm_workers_sec_group.security_group_id
# }

# resource "mgc_network_security_groups_rules" "allow_tcp" {
#   for_each          = toset(var.allowed_tcp_ports)
#   description       = "Allow incoming TCP"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = each.key
#   port_range_min    = each.key
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = mgc_network_security_groups.swarm_managers_sec_group.security_group_id
# }

# resource "mgc_network_security_groups_rules" "allow_udp" {
#   for_each          = toset(var.allowed_tcp_ports)
#   description       = "Allow incoming UDP"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = each.key
#   port_range_min    = each.key
#   protocol          = "udp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = mgc_network_security_groups.swarm_managers_sec_group.security_group_id
# }
terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.29.2"
    }
  }
}

resource "mgc_network_vpcs" "swarm_vpc" {
  name = "${var.project_name}-swarm-vpc"
  # description = "${var.project_name}-swarm-vpc"
}

resource "mgc_network_security_groups" "swarm_managers_sec_group" {
  name = "${var.project_name}-swarm-managers-sec-group"
}

resource "mgc_network_security_groups" "swarm_workers_sec_group" {
  name = "${var.project_name}-swarm-workers-sec-group"
}

resource "mgc_network_security_groups" "allow_ssh_sec_group" {
  name = "${var.project_name}-ssh-sec-group"
}

resource "mgc_network_security_groups_rules" "allow_ssh" {
  for_each          = { "IPv4" : "0.0.0.0/0", "IPv6" : "::/0" }
  direction         = "ingress"
  ethertype         = each.key
  port_range_max    = 22
  port_range_min    = 22
  protocol          = "tcp"
  remote_ip_prefix  = each.value
  security_group_id = mgc_network_security_groups.allow_ssh_sec_group.id
}

resource "mgc_network_security_groups_rules" "allow_tcp_managers" {
  for_each          = toset([for port in var.allowed_tcp_ports : tostring(port)])
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = each.key
  port_range_min    = each.key
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.swarm_managers_sec_group.id
}

resource "mgc_network_security_groups_rules" "allow_udp_managers" {
  for_each          = toset([for port in var.allowed_tcp_ports : tostring(port)])
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = each.key
  port_range_min    = each.key
  protocol          = "udp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.swarm_managers_sec_group.id
}

resource "mgc_network_security_groups_rules" "allow_tcp_workers" {
  for_each          = toset([for port in var.allowed_tcp_ports : tostring(port)])
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = each.key
  port_range_min    = each.key
  protocol          = "tcp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.swarm_workers_sec_group.id
}

resource "mgc_network_security_groups_rules" "allow_udp_workers" {
  for_each          = toset([for port in var.allowed_tcp_ports : tostring(port)])
  direction         = "ingress"
  ethertype         = "IPv4"
  port_range_max    = each.key
  port_range_min    = each.key
  protocol          = "udp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = mgc_network_security_groups.swarm_workers_sec_group.id
}

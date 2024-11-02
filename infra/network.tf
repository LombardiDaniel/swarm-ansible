# https://www.youtube.com/watch?v=nMVXs8VnrF4
# resource "mgc_network_vpc" "swarm_vpc" {
#   provider    = mgc.sudeste
#   name        = "${var.project_name}-swarm-vpc"
#   description = "${var.project_name}-swarm-vpc"
# }

# resource "mgc_network_security_groups" "swarm_managers_sec_group" {
#   provider = mgc.sudeste
#   name     = "${var.project_name}-swarm-managers-sec-group"
# }
# resource "mgc_network_security_groups" "swarm_workers_sec_group" {
#   provider = mgc.sudeste
#   name     = "${var.project_name}-swarm-workers-sec-group"
# }
# resource "mgc_network_security_groups_rules" "allow_ssh" {
#   description       = "Allow incoming SSH traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 22
#   port_range_min    = 22
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = var.swarm_managers_sec_group
# }
# resource "mgc_network_security_groups_rules" "allow_ssh" {
#   description       = "Allow incoming SSH traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 22
#   port_range_min    = 22
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = var.swarm_workers_sec_group
# }
# resource "mgc_network_security_groups_rules" "allow_http" {
#   description       = "Allow incoming HTTP traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 80
#   port_range_min    = 80
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = var.swarm_managers_sec_group
# }
# resource "mgc_network_security_groups_rules" "allow_https" {
#   description       = "Allow incoming HTTPS traffic"
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   port_range_max    = 443
#   port_range_min    = 443
#   protocol          = "tcp"
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = var.swarm_managers_sec_group
# }
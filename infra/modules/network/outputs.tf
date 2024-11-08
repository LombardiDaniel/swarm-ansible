output "vpc_id" {
  value = mgc_network_vpcs.swarm_vpc.id
}

output "ssh_sec_group_id" {
  value = mgc_network_security_groups.allow_ssh_sec_group.id
}

output "swarm_managers_sec_group_id" {
  value = mgc_network_security_groups.swarm_managers_sec_group.id
}

output "swarm_workers_sec_group_id" {
  value = mgc_network_security_groups.swarm_workers_sec_group.id
}

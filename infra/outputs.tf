output "majority_on_cluster_size" {
  value = <<-EOT
Docker-Swarm Cluster:
Cluter Size: ${var.cluster_size}
Marjority: ${local.cluster_majority}
EOT
}


output "created_cluster" {
  value = <<-EOT
ManagerNodes PublicIPs:
%{for i in mgc_virtual_machine_instances.manager_nodes_vms[*]~}
${i.network.public_address}
%{endfor~}
WorkerNodes PrivateIPs:
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network.private_address}
%{endfor~}
EOT
}

resource "local_file" "hosts_ini" {
  filename = var.hosts_ini_path
  content  = <<-EOT
[node0]
${mgc_network_public_ips.manager_pub_ips[0].public_ip}

[all]
%{for i in mgc_network_public_ips.manager_pub_ips[*]~}
${i.ip}
%{endfor~}
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network_interfaces[0].private_address} ansible_ssh_common_args="-J ubuntu@${mgc_network_public_ips.manager_pub_ips[0].public_ip}"
%{endfor~}

[managers]
%{for i in mgc_virtual_machine_instances.manager_nodes_vms[*]~}
${i.network.public_address}
%{endfor~}

[workers]
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network_interfaces[0].private_address} ansible_ssh_common_args="-J ubuntu@${mgc_network_public_ips.manager_pub_ips[0].public_ip}"
%{endfor~}

EOT
}

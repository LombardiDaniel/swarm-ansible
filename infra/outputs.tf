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
${i.network_interfaces[0].ipv4}
%{endfor~}
WorkerNodes PrivateIPs:
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network_interfaces[0].local_ipv4}
%{endfor~}
EOT
}

resource "local_file" "hosts_ini" {
  filename = var.hosts_ini_path
  content  = <<-EOT
[node0]
${mgc_virtual_machine_instances.manager_nodes_vms[0].network_interfaces[0].ipv4}

[all]
%{for i in mgc_virtual_machine_instances.manager_nodes_vms[*]~}
${i.network_interfaces[0].ipv4}
%{endfor~}
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network_interfaces[0].local_ipv4} ansible_ssh_common_args="-J ubuntu@${mgc_virtual_machine_instances.manager_nodes_vms[0].network_interfaces[0].ipv4}"
%{endfor~}

[managers]
%{for i in mgc_virtual_machine_instances.manager_nodes_vms[*]~}
${i.network_interfaces[0].ipv4}
%{endfor~}

[workers]
%{for i in mgc_virtual_machine_instances.worker_nodes_vms[*]~}
${i.network_interfaces[0].local_ipv4} ansible_ssh_common_args="-J ubuntu@${mgc_virtual_machine_instances.manager_nodes_vms[0].network_interfaces[0].ipv4}"
%{endfor~}

EOT
}

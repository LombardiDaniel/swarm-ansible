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
%{for i in mgc_virtual_machine_instances.manager_nodes_instances[*]~}
${i.network.public_address}
%{endfor~}
WorkerNodes PrivateIPs:
%{for i in mgc_virtual_machine_instances.worker_nodes_instances[*]~}
${i.network.private_address}
%{endfor~}
EOT
}

resource "local_file" "hosts_ini" {
  filename = var.hosts_ini_path
  content  = <<-EOT
[node0]
${mgc_virtual_machine_instances.manager_nodes_instances[0].network.public_address}

[all]
%{for i in mgc_virtual_machine_instances.manager_nodes_instances[*]~}
${i.network.public_address}
%{endfor~}
%{for i in mgc_virtual_machine_instances.worker_nodes_instances[*]~}
${i.network.private_address} ansible_ssh_common_args="-o StrictHostKeyChecking=no -J ubuntu@${mgc_virtual_machine_instances.manager_nodes_instances[0].network.public_address}"
%{endfor~}

[managers]
%{for i in mgc_virtual_machine_instances.manager_nodes_instances[*]~}
${i.network.public_address}
%{endfor~}

[workers]
%{for i in mgc_virtual_machine_instances.worker_nodes_instances[*]~}
${i.network.private_address} ansible_ssh_common_args="-o StrictHostKeyChecking=no -J ubuntu@${mgc_virtual_machine_instances.manager_nodes_instances[0].network.public_address}"
%{endfor~}

EOT
}

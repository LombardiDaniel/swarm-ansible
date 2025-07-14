terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.33.0"
    }
  }
}

module "network" {
  source = "./modules/network"

  api_key           = var.api_key
  project_name      = var.project_name
  vpc_id            = var.vpc_id
  allowed_tcp_ports = [80, 443, 2377, 7946]
  allowed_udp_ports = [4789]
}

locals {
  cluster_majority = floor(0.5 + (var.cluster_size + 1) / 2)
  cluster_minority = var.cluster_size - local.cluster_majority
}

resource "mgc_ssh_keys" "cluster_ssh_key" {
  name = "${var.project_name}-ssh-key"
  key  = var.ssh_pub_key
}

resource "mgc_network_public_ips" "manager_pub_ips" {
  count       = local.cluster_majority
  description = "${var.project_name}-swarm-manager-${count.index}"
  vpc_id      = var.vpc_id
}

resource "mgc_virtual_machine_instances" "manager_nodes_vms" {
  count        = local.cluster_majority
  name         = "${var.project_name}-swarm-manager-${count.index}"
  machine_type = var.machine_type
  image        = "cloud-ubuntu-22.04 LTS"
  ssh_key_name = mgc_ssh_keys.cluster_ssh_key.name
}

resource "mgc_virtual_machine_instances" "worker_nodes_vms" {
  count        = local.cluster_minority
  name         = "${var.project_name}-swarm-worker-${count.index}"
  machine_type = var.machine_type
  image        = "cloud-ubuntu-22.04 LTS"
  ssh_key_name = mgc_ssh_keys.cluster_ssh_key.name
}

resource "mgc_network_public_ips_attach" "pub_ip_attachs" {
  for_each     = { for idx, vm in mgc_virtual_machine_instances.manager_nodes_vms : tostring(idx) => vm }
  public_ip_id = mgc_network_public_ips.manager_pub_ips[each.key].id
  interface_id = each.value.network_interfaces[0].id
}

resource "mgc_network_security_groups_attach" "ssh_security_group_attach" {
  for_each          = { for idx, vm in concat(mgc_virtual_machine_instances.manager_nodes_vms, mgc_virtual_machine_instances.worker_nodes_vms) : tostring(idx) => vm }
  interface_id      = each.value.network_interfaces[0].id
  security_group_id = module.network.ssh_sec_group_id
}

resource "mgc_network_security_groups_attach" "managers_security_group_attach" {
  for_each          = { for idx, vm in mgc_virtual_machine_instances.manager_nodes_vms : tostring(idx) => vm }
  interface_id      = each.value.network_interfaces[0].id
  security_group_id = module.network.swarm_managers_sec_group_id
}

resource "mgc_network_security_groups_attach" "workers_security_group_attach" {
  for_each          = { for idx, vm in mgc_virtual_machine_instances.worker_nodes_vms : tostring(idx) => vm }
  interface_id      = each.value.network_interfaces[0].id
  security_group_id = module.network.swarm_managers_sec_group_id
}

resource "time_sleep" "wait_60_seconds" {
  count = var.run_ansible ? 1 : 0
  depends_on = [
    mgc_virtual_machine_instances.manager_nodes_vms,
    mgc_virtual_machine_instances.worker_nodes_vms,
  ]
  create_duration = "60s"
}

resource "null_resource" "execute_ansible_on_local" {
  depends_on = [
    time_sleep.wait_60_seconds
  ]
  count = var.run_ansible ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
    ansible-playbook -u ubuntu -i hosts/hosts.ini playbooks/setup.yml && 
    ansible-playbook -u ubuntu -i hosts/hosts.ini playbooks/bootstrap_swarm.yml && 
    ansible-playbook -u ubuntu -i hosts/hosts.ini --extra-vars @vars.yml playbooks/bootstrap_essential_services.yml
    EOT

    working_dir = "../"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = "False"
    }
  }
}

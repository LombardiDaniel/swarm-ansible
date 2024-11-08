terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.29.2"
    }
  }
}

module "network" {
  source = "./modules/network"

  api_key           = var.api_key
  project_name      = var.project_name
  allowed_tcp_ports = [80, 443, 2377, 7946]
  allowed_udp_ports = [4789]
}

locals {
  cluster_majority = floor(0.5 + (var.cluster_size + 1) / 2)
  cluster_minority = var.cluster_size - local.cluster_majority
}

resource "mgc_virtual_machine_instances" "manager_nodes_instances" {
  count = local.cluster_majority
  name  = "${var.project_name}-swarm-manager-${count.index}"
  machine_type = {
    name = var.machine_type
  }
  image = {
    name = "cloud-ubuntu-22.04 LTS"
  }
  network = {
    vpc = {
      id = module.network.vpc_id
    }
    associate_public_ip = true
    delete_public_ip    = false
    interface = {
      security_groups = [
        { id = module.network.ssh_sec_group_id },
        { id = module.network.swarm_managers_sec_group_id },
      ]
    }
  }

  ssh_key_name = var.ssh_key_name
}

resource "mgc_virtual_machine_instances" "worker_nodes_instances" {
  provider = mgc.sudeste
  count    = local.cluster_minority
  name     = "${var.project_name}-swarm-worker-${count.index}"
  machine_type = {
    name = var.machine_type
  }
  image = {
    name = "cloud-ubuntu-22.04 LTS"
  }
  network = {
    vpc = {
      id = module.network.vpc_id
    }
    associate_public_ip = false
    delete_public_ip    = false
    interface = {
      security_groups = [
        { id = module.network.ssh_sec_group_id },
        { id = module.network.swarm_workers_sec_group_id },
      ]
    }
  }

  ssh_key_name = var.ssh_key_name
}

resource "time_sleep" "wait_60_seconds" {
  count = var.run_ansible ? 1 : 0
  depends_on = [
    mgc_virtual_machine_instances.manager_nodes_instances,
    mgc_virtual_machine_instances.worker_nodes_instances,
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

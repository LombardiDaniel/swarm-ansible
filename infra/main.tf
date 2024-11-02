terraform {
  required_providers {
    mgc = {
      source  = "magalucloud/mgc"
      version = "0.27.1"
    }
  }
}

provider "time" {}

provider "mgc" {
  alias  = "sudeste"
  region = "br-se1"
}

locals {
  cluster_majority = floor(0.5 + (var.cluster_size + 1) / 2)
  cluster_minority = var.cluster_size - local.cluster_majority
}

resource "mgc_virtual_machine_instances" "manager_nodes_instances" {
  provider = mgc.sudeste
  count    = local.cluster_majority
  name     = "${var.project_name}-swarm-manger-${count.index}"
  machine_type = {
    name = var.machine_type
  }
  image = {
    name = "cloud-ubuntu-22.04 LTS"
  }
  network = {
    # vpc = {
    #   id = mgc_network_vpc.swarm_vpc.network_id
    # }
    associate_public_ip = true
    delete_public_ip    = false
    interface = {
      security_groups = [
        for id in var.manager_sec_group_ids : {
          id = id
        }
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
    # vpc = {
    #   id = mgc_network_vpc.swarm_vpc.network_id
    # }
    associate_public_ip = false
    delete_public_ip    = false
    interface = {
      security_groups = [
        for id in var.worker_sec_group_ids : {
          id = id
        }
      ]
    }
  }

  ssh_key_name = var.ssh_key_name
}

resource "time_sleep" "wait_60_seconds" {
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

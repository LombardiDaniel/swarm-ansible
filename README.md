# Automated Docker Swarm bootstrap using Ansible

> Ei você! É BR? Dá uma olhada em [/infra](/infra/) onde já temos manifestos terraform pra maior e melhor [MagaluCloud](https://magalu.cloud/)! Com um comando, um cluster inteiro configurado (já rodamos os playbooks ansible junto com o terraform pra vc)!

Build a Docker Swarm cluster using Ansible with swarm. The goal is to rapidly bootstrap a Docker Swarm cluster on machines running: Debian; Ubuntu.

#### 🚨 Disclaimer:

This repo aims to be a **simple** (however somewhat production-ready) bootstrap of a docker swarm cluster using default configs, **especially** for the services in available [composes](/composes/). If you would like more configuration options (considering for security), please read their respective documentations and configure them manually. I advise to NOT run any databases on this setup. Hosting of databases is complicated, it is better to just pay a service to do that for us, or use a free-tier (there are many).

---

### ✅ System Requirements

- Control Node (the machine you will be running the Ansible commands). I am using Ansible 2.15.1.
  - [Anisble](https://www.ansible.com/)
  - [Terraform](https://www.terraform.io/)
- All swarm nodes (manager and workers) should have passwordless SSH access, this can be setup by passing your SSH public keys when you create your VM. You can also check this [Digital Ocean Guide](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server) to set up ssh key based authentication on linux machines.

## 🚀 Getting Started

### 💻 Hardware we will use

For this example, we will be using [MagaluCloud](https://magalu.cloud/), but it also works with seamlessly with [Oracle Cloud Allways-Free Tier](https://www.oracle.com/cloud/free/).

For this demo, we are using 3 machines:

- 3x BV4-8-100: 4vCPU 8GB of RAM and 100GB disk space

Since docker swarm is a distributed container orchestration tool, we need `manager` and `worker` nodes. Add the public-ip (for more advanced users; yes, you can use a bastion and keep the worker nodes unaccessible publicly) of all manager nodes (in our case, just the left one) to your DNS, as traefik (the reverse proxy we will be using must run on managers to retrieve info about the swarm). The needed ports for communication between the nodes are: `:2377` (TCP), `:7946` (TCP/UDP) and `:4789`(UDP), remember to allow traffic on these ports.

> You should maintain an odd number of managers in the swarm to support manager node failures. Having an odd number of managers ensures that during a network partition, there is a higher chance that the quorum remains available to process requests if the network is partitioned into two sets. Keeping the quorum is not guaranteed if you encounter more than two network partitions. https://docs.docker.com/engine/swarm/admin_guide/#add-manager-nodes-for-fault-tolerance

Our architecture will look something like this (if you decide to bootstrap included services):

![architecture](/arch.png)

The DNS will point to our manager nodes (in this case, `node-0` and `node-1`) and traefik will be exposed on port 80 (HTTP) and 443 (HTTPS), we also set up redirection of port 80 -> 443 via traefik. Note that the `my-app` instance access the database without being exposed directly to the web, the "my-app-net" is a docker network with the `overlay` driver, this means that it exists on all nodes, allowing for inter-node comunication.

### 🍴Preparation

The first thing we need to do after getting our hardware ready is create a [hosts.ini](hosts/hosts.ini) file. You must have at least one manager node.

```ini
[node0]  # The node you will use to run init the swarm (must be a manager)
1.2.3.4

[all]  # all nodes public ips
1.2.3.4
1.2.3.5
1.2.3.6

[managers]  # manager nodes public ips
1.2.3.4

[workers]  # worker nodes public ips
1.2.3.5
1.2.3.6
```

You will have to change the remote user by passing the `-u REMOTE_USER` flag in the ansible comands.

## 🐳 Creating the Cluster

After creating your hosts file and configuring the default remote user, we can start running the playbooks.

To setup the cluster and install dependencies:

> NOTE: this command DISABLES iptables firewall, do NOT host services on bare-metal after this.

```sh
ansible-playbook -u REMOTE_USER -i hosts/hosts.ini playbooks/setup.yml
```

Then, to initiailze the cluster:

```sh
ansible-playbook -u REMOTE_USER -i hosts/hosts.ini playbooks/bootstrap_swarm.yml
```

The script already takes care of the different swarm join tokens, so there is no need for extra configuration.

If anything goes wrong or you just want to dismantle the swarm, simply run:

```sh
ansible-playbook -u REMOTE_USER -i hosts/hosts.ini playbooks/dismantle_swarm.yml
```

## 🚚 Base Services

If you also want to bootstrap some base services, you can use this section to do so. The services that will be installed here are:

- [Traefik](https://doc.traefik.io/traefik/) - Reverse Proxy and Load Balancer to access the cluster services
- [Portainer](https://www.portainer.io/) - Container Orchestration web UI
- [Registry](https://hub.docker.com/_/registry) - Container (private) Registry for your docker images - Note that we are going to be using simple HttpAuth, check [this](https://medium.com/@maanadev/authorization-for-private-docker-registry-d1f6bf74552f) for other options
- [SwarmCronjob](https://crazymax.dev/swarm-cronjob/) - **Simple** cronjob solution
- [Shepherd](https://github.com/containrrr/shepherd/) - Update your services on image update
- [Dozzle](https://dozzle.dev/) - Simple logging and monitoring

To bootstrap these services, we'll need to do a tiny bit more configuring. To use traefik, we'll need a domain name (configure the DNS to point both `example.com` and `*.example.com` to the managers ip's), and since in this example we use it to create SSL certificates, we need a maintainer email. To configure it, go to [vars.yml](/vars.yml):

```yaml
domain_name: cloud.example.com # <- your domain
maintainer_email: my.email@email.com # <- your email
basic_auth_password: adminPass # <- registry and traefik http password (user is admin)
```

Since we uploaded our own private container registry, we can deploy our services with a simple CI/CD build such as [GitHub Actions](https://docs.github.com/en/actions), just build and push to your registry, it will be available at [https://registry.YOUR_DOMAIN_NAME/](https://registry.YOUR_DOMAIN_NAME/), then Shepherd will update it automatically. You can also check the registry UI at [https://registry-ui.YOUR_DOMAIN_NAME/](https://registry-ui.YOUR_DOMAIN_NAME/).

After configuring it, simply run:

```sh
ansible-playbook -u REMOTE_USER -i hosts/hosts.ini --extra-vars @vars.yml playbooks/bootstrap_essential_services.yml
```

Traefik will take a few moments to generate the TLS certificates but after that, you can access those services with their subdomain. For example:

Portainer: `https://portainer.example.com`

Remember that in the case of portainer, you have a limited ammount of time to access it and create the admin user, if you don't, you'll need to restart the container service (on a manager node: `docker service update portainer_portainer`).

#### 🗒️ NOTEs:

- traefik http_pass config is: `admin:adminPass`, to change it, take a look at [composes/traefik/replace_pass.sh](/composes/traefik/replace_pass.sh).
- the portainer version we are running is the Community Edition (CE), you can run the Enterprise Edition (EE) for [free for up to 3-nodes](https://www.portainer.io/take-3) it gives some pretty cool functionality, check it out.

### 👟 Running your own services

Since we have a small cluster with very limited resources, it is pretty important to set resource limits in the compose files. To create the routes in traefik, you must add these labels to the `deploy` segment in the compose file. Take a look at the following example:

```yaml
version: "3.7"

services:
  my-app:
    image: my-app:prod
    networks:
      - traefik-public # this allows the container to be accessed by traefik
    deploy:
      resouces:
        limits:
          cpus: "0.50"
          memory: 50M
      # placement:  # more details below
      #   preferences:
      #     - spread: node.labels.az
      replicas: 3
      mode: replicated # or "global" -> on all nodes
      labels:
        - shepherd.autodeploy=true # this will make shepherd watch for updates (on image tagged with "my-app:prod")
        - traefik.enable=true
        - traefik.http.services.${MY_SERVICE_NAME}.loadbalancer.server.port=${TARGET_PORT}
        - traefik.http.routers.${MY_SERVICE_NAME}.rule=Host(`${SUBDOMAIN_TO_REDIRECT}.${DOMAIN_NAME}`)
        - traefik.http.routers.${MY_SERVICE_NAME}.entrypoints=websecure
        - traefik.http.routers.${MY_SERVICE_NAME}.tls=true
        - traefik.http.routers.${MY_SERVICE_NAME}.tls.certresolver=leresolver
        # - traefik.http.routers.${MY_SERVICE_NAME}.service=${MY_SERVICE_NAME} # only needed if going to use more than 1 route (port) per service
        # - traefik.http.routers.${MY_SERVICE_NAME}.middlewares=admin-auth  # this line enables the admin-auth on the service

networks:
  traefik-public:
    driver: overlay
    external: true
```

```sh
docker stack deploy -c compose.yml MY_STACK_NAME --with-registry-auth
```

In this yaml snippet, we have 4 vars:

- MY_SERVICE_NAME: The name of the service in the compose file (i.e. "my-app", the name defined in the compose)
- SUBDOMAIN_TO_REDIRECT: The subdomain used to redirect to that service
- DOMAIN_NAME: Your domain name (can be used in conjunction with the subdomain to redirect from a whole new domain)
- TARGET_PORT: The port where the service is running in it's container

After this, check:

- [https://portinaer.example.com](https://portinaer.example.com)
- [https://registry.example.com](https://registry.example.com)
- [https://registry-ui.example.com](https://registry-ui.example.com)
- [https://traefik.example.com](https://traefik.example.com)
- [https://dozzle.example.com](https://dozzle.example.com)

The user is `admin` and the password is the one you previously configured.

### Other cool stuff you can do

Docker Swarm also supports `node-labels`, so you can seperate availability zones (for example):

```sh
docker node update \
  --label-add az=1 \
  NODE_HOSTNAME_OR_ID
```

and use it with:

```sh
docker service create \
  --placement-pref "spread=node.labels.az" \
  my_service
```

This will make sure the service containers are distributed evenly on nodes with different `az` labels.

Take a look at [examples](/examples/) to see examples of:

- Stateful apps running in the cluster (take a note at the placement constraints in the compose).
- A reverse proxy (L7) configuration; for L4, you'll have to run an HAProxy (or your LB of preference) and map the ports `host:container`, routing them manually, just remember to configure the container to be restrained to a single (manager) node so there is no chance of it's IP changing.
- Example GitHub Actions Workflow CI (with multi-arch, needed for heterogeneous clouds) file that ends up triggering the shepherd daemon to do the CD locally in the cluster. The image tags to push on that workflow are: `repository-name:branch-name`.

### 🍪 Thanks

This repo was somewhat inspired by [tecno-tim's k3s-ansible](https://github.com/techno-tim/k3s-ansible). Check him out!

- [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible)
- [Under the Hood with Docker Swarm Mode](https://www.youtube.com/watch?v=Mw4ImA2IB10)
- Hat tip to everyone who's code was used!

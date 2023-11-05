#!/bin/bash

#### NOTE:
#   traefik seems to (as of now) have errors when working with encrypted networks:
#   https://github.com/traefik/traefik/issues/3581
#   https://github.com/moby/moby/issues/37115

# docker network create --opt encrypted --driver overlay --attachable traefik-public
docker network create --driver overlay --attachable traefik-public

#!/bin/bash

# We need double "$" so that docker-compose escapes it correctly

echo $(htpasswd -nb admin myDifficultP@ssword) | sed -e s/\\$/\\$\\$/g
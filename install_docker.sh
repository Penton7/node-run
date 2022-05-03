#!/usr/bin/bash

sudo apt-get update

sudo apt-get install -y docker.io

sudo usermod -aG docker $USER

newgrp docker

docker run -d -p 26657:26657 -p 6060:6060 --name gitopia djinno/docker-gitopia-node:latest

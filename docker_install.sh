#!/bin/bash

sudo apt-get update && sudo apt get upgrade

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
    
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

# add current user to docker group so there is no need to use sudo when running docker
sudo usermod -aG docker $(whoami)
#!/bin/bash

# Check dir 
check_dir() {
    if [ -d "Ansible" ]; then
            echo "Directory Ansible already exist"
    else
            echo "Make Ansible Directory"
            echo -n "Enter git URL : "
            read giturl
            git clone $giturl
    fi
}

# Menu installation
menu_list() {
        echo "1. Config User"
        echo "2. Ansible"
        echo "3. Docker"
        echo "4. Kubernetes"
        echo "5. Calico Pod Network Add-on"
        echo "6. Cilium Pod Network Add-on"
        echo "7. Antrea Pod Network Add-on"
        echo "================================="
        echo -n "Pick to install [1/2/3/4/5/6/7] : "
}

# debian Update & Upgrade
sudo apt-get update && sudo apt-get upgrade -y

answer=8
menu_list

# Loop installation
while [ $answer -eq 8 ]; do
        read answer

        if [ $answer -eq 1 ]; then
                echo "User Configuration"
                echo -n "Enter your Username : "
                read username
                sudo adduser $username
                sudo usermod -aG sudo $username
                sudo nano /etc/ssh/sshd.config
                echo "Restart sshd.service"
                sudo systemctl restart sshd.service
        elif [ $answer -eq 2 ]; then
                echo "Ansible Installation"
                sudo apt install software-properties-common
                sudo apt-add-repository --yes --update ppa:ansible/ansible
                sudo apt install ansible
                echo "Don't forget to setup inventory and ansible.cfg"
        elif [ $answer -eq 3 ]; then
                echo "Docker Installation"
                echo "Set up Repository"
                sudo apt-get install -y \
                    apt-transport-https \
                    ca-certificates \
                    curl \
                    software-properties-common
                echo "Add Docker official GPG Key"
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
                echo "Verify key with the fingerprint"
                sudo apt-key fingerprint 0EBFCD88
                echo "Using stable repository"
                sudo add-apt-repository \
                    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
                    $(lsb_release -cs) \
                    stable"
                echo "Install Docker engine"
                sudo apt-get update
                sudo apt-get install docker-ce docker-ce-cli containerd.io
                echo "Add current user to docker group"
                sudo usermod -aG docker $(whoami)
        elif [ $answer -eq 4 ]; then
                echo "Kubernetes Installation"
                sudo apt install -y apt-transport-https curl
                curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
                sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
                sudo apt update
                echo "Install kubelet kubeadm kubectl"
                sudo apt install -y kubelet kubeadm kubectl
                echo "initialize kubeadm from node master"
                echo -n "Enter IP Master : "
                read ip_master
                kubeadm init --apiserver-advertise-address=$ip_master --pod-network-cidr=192.168.0.0/16
                echo "After initialize don't forget to checking nodes = kubectl get nodes"
                echo "Start using Cluster as a reguler user"
                mkdir -p $HOME/.kube
                sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
                sudo chown $(id -u):$(id -g) $HOME/.kube/config
                kubectl get nodes
        elif [ $answer -eq 5 ]; then
                echo "Deploy Calico Pod Network"
                kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
                kubectl get nodes
        elif [ $answer -eq 6 ]; then
                echo "Deploy Cilium Pod Network"
                echo "Install helm v3 before deploy Cilium Pod Network"
                curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
                sudo apt-get install apt-transport-https --yes
                echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
                sudo apt-get update
                sudo apt-get install helm
                echo "Add Helm Repo"
                helm repo add cilium https://helm.cilium.io/
                echo "Deploy Cilium release via Helm"
                helm install cilium |CHART_RELEASE| --namespace kube-system
                kubectl get nodes
        elif [ $answer -eq 7 ]; then
                echo "Deploy Antrea Pod Network"
                echo "Recommended version = v0.12.0 v0.11.0 v0.10.1"
                echo -n "Enter Antrea TAG version : "
                read TAG
                kubectl apply -f https://github.com/vmware-tanzu/antrea/releases/download/$TAG/antrea.yml
                kubectl get nodes
        else
                menu_list
                answer=8
        fi
done

echo "============================================================="
echo "############       Script Has Been Over       ###############"
echo "############           by Peruvian            ###############"
echo "============================================================="
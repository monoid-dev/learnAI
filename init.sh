#!/bin/bash

# Monoid's graphics card test program  v1.1, Sep 30,2018
# Copyright (C) 2018 yujmo <yujmo94@gmail.com>

# This program is free software; you can redistribute it and/or modify it 
# under the terms of the GNU General Public License as published by 
# the Free Software Foundation; either version 2 of the License, 
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
# or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program; 
# if not, see <http://www.gnu.org/licenses>.

replace_source(){
    add-apt-repository ppa:graphics-drivers/ppa -y
    echo -e "deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe
deb http://mirrors.aliyun.com/ubuntu/ xenial multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security universe
deb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse" > /etc/apt/sources.list
}

nvidia_driver(){
    wget http://www.openfaas.cn/drivers/cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64.deb  && dpkg -i cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64.deb
    apt-key add /var/cuda-repo-10-0-local-10.0.130-410.48/7fa2af80.pub
    apt-get update && apt-get install cuda -y
}

uninstall_driver(){
     apt-get remove --purge nvidia*
}

nvidia_docker2(){
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

    apt-get update && apt-get install -y nvidia-docker2 && pkill -SIGHUP dockerd
echo -e "{
    \"registry-mirrors\": [\"https://ld7jqf2j.mirror.aliyuncs.com\"],
    \"default-runtime\": \"nvidia\",
    \"runtimes\": {
        \"nvidia\": {
            \"path\": \"nvidia-container-runtime\",
            \"runtimeArgs\": []
        }
      }
}" > /etc/docker/daemon.json
    systemctl restart docker
}

build_image(){
     wget http://www.openfaas.cn/codes/cifar10.zip && unzip cifar10.zip
     cd cifar10 && docker build -t test .
}

docker_ce(){
    apt-get -y install apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    apt-get -y update
    apt-get -y install docker-ce
    /lib/systemd/systemd-sysv-install enable docker
}

pull_image(){
    #docker pull nvidia/cuda
    #docker pull tensorflow/tensorflow:latest-gpu-py3
    docker pull yujmo/tensorflow:1.9.0-gpu-py3
}

init_system(){

    apt-get install openssh-server -y && 
    /lib/systemd/systemd-sysv-install enable ssh
    sed -i 's/#   StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config 
    sed -i 's/StrictHostKeyChecking ask/StrictHostKeyChecking no/' /etc/ssh/ssh_config 
    apt-get remove libappstream3 -y && apt-get update && apt-get install --reinstall software-center -y
    apt-get install --reinstall software-center software-center-aptdaemon-plugin -y
    apt-get upgrade -y
}

echo -e "Now,we will install the gtx driver and test it with nvidia-docker"


#replace_source
init_system
docker_ce
#uninstall_driver
#nvidia_driver
nvidia_docker2
pull_image

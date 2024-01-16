#!/bin/bash

# remove existing docker version because current version does not work with nvidia toolkits
sudo apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli docker-compose-plugin
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce docker-compose-plugin

# install the correct version of docker and nvidia toolkits
export VERSION_STRING=5:20.10.24~3-0~ubuntu-jammy
sudo apt-get install -y docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io docker-compose-plugin
sudo apt-get install -y nvidia-container-runtime nvidia-container-toolkit

# add the nvidia runtime to docker
sudo cat >/etc/docker/daemon.json <<EOL
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
         } 
    },
    "default-runtime": "nvidia" 
}
EOL

# restart docker to pick up the new environment
sudo systemctl restart docker
sudo systemctl daemon-reload

# validate the runtime is there
sudo docker info | grep -i runtime

# import the .env file
set -o allexport; source .env; set +o allexport

# clone the threestudio and dreamcraft projects
git clone https://github.com/threestudio-project/threestudio.git
cd ./threestudio/custom
git clone https://github.com/DSaurus/threestudio-dreamcraft3D.git

cd ..

echo "downloading zero123-xl.ckpt...press CTRL-C to cancel"
if ! test -f ./load/zero123/stable_zero123.ckpt; then
  cd load/zero123
  sudo bash download.sh
  cp zero123-xl.ckpt stable_zero123.ckpt
  cd ../../
fi

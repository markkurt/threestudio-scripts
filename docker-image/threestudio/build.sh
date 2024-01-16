#!/bin/bash
cp ../../threestudio/requirements.txt .
DOCKER_BUILDKIT=0 sudo docker build -t threestudio .
sudo docker image tag threestudio mckurt/threestudio:latest
sudo docker push mckurt/threestudio:latest
rm requirements.txt

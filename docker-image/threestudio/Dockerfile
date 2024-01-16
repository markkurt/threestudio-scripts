FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04
WORKDIR /root/

# Setup for nvidia-docker
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.8"

RUN apt-get update -y
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y software-properties-common git python3-pip libegl1-mesa-dev
RUN pip install virtualenv

WORKDIR /root
RUN python3 -m virtualenv venv

COPY requirements.txt ./tmp/requirements.txt
WORKDIR /root/tmp

RUN . ../venv/bin/activate && pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
RUN . ../venv/bin/activate && pip install ninja
RUN . ../venv/bin/activate && pip install -r requirements.txt
RUN . ../venv/bin/activate && pip install -U xformers --index-url https://download.pytorch.org/whl/cu118
RUN . ../venv/bin/activate && pip install diffusers==0.24.0

RUN . ../venv/bin/activate && pip install mediapipe
RUN . ../venv/bin/activate && pip install backgroundremover

WORKDIR /root


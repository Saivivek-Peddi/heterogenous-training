#!/bin/bash

# Update and upgrade system
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary tools
sudo apt-get install -y build-essential git

# Install MPI
sudo apt-get install -y mpich

# Install Python and PIP
sudo apt-get install -y python3-pip
pip3 install --upgrade pip

# Install necessary Python packages
pip3 install numpy mpi4py

# Setup for Nvidia GPU
sudo apt-get install -y nvidia-cuda-toolkit
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113

# Reminder to reboot your machine to finalize GPU driver installations
echo "Please reboot your machine to finalize GPU driver installations."

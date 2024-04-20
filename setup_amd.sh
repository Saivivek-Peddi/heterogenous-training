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

# Setup for AMD GPU
# Follow the official ROCm installation guide: https://rocmdocs.amd.com/en/latest/Installation_Guide/Installation-Guide.html
echo 'deb [arch=amd64] https://repo.radeon.com/rocm/apt/debian/ xenial main' | sudo tee /etc/apt/sources.list.d/rocm.list
sudo apt-key adv --fetch-keys http://repo.radeon.com/rocm/apt/debian/rocm.gpg.key
sudo apt-get update
sudo apt-get install -y rocm-dkms rocm-libs rocblas rocrand
echo 'export PATH=$PATH:/opt/rocm/bin' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm/lib' >> ~/.bashrc
source ~/.bashrc
pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/rocm5.0

# Reminder to reboot your machine to finalize GPU driver installations
echo "Please reboot your machine to finalize GPU driver installations."

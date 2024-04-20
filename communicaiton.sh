#!/bin/bash

# Check if running as root, if not, remind to run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Update system and install required packages
echo "Updating system and installing required packages..."
sudo apt-get update
sudo apt-get install -y openmpi-bin openmpi-common openssh-client openssh-server libopenmpi-dev

# Environment variables for hostnames
echo "Exporting hostnames as environment variables..."
echo "export NVIDIA_NODE_HOSTNAME=<Nvidia-Node-IP>" >> /etc/environment
echo "export AMD_NODE_HOSTNAME=<AMD-Node-IP>" >> /etc/environment

# Load the new environment variables
source /etc/environment

# Generate SSH keys if not present
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "SSH key not found. Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
else
    echo "SSH key already exists. Skipping generation..."
fi

# Copy the public key to the remote host for passwordless SSH
# Determine if running on Nvidia or AMD node by simple hostname check
if [[ $(hostname) == *nvidia* ]]; then
    REMOTE_HOSTNAME=$AMD_NODE_HOSTNAME
else
    REMOTE_HOSTNAME=$NVIDIA_NODE_HOSTNAME
fi

echo "Copying SSH key to $REMOTE_HOSTNAME for passwordless SSH access..."
ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@$REMOTE_HOSTNAME

echo "Communication setup complete. You can now use MPI across nodes without manually specifying hostnames."

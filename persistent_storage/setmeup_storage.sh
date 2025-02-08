#!/bin/bash

# Variables
VOLUME_ID="vol-xxxxxxxxxxxxxxxxx"  # Replace with your EBS Volume ID
DEVICE_NAME="/dev/xvdf"
MOUNT_POINT="/mnt/ollama-models"

# Check if the volume is attached
ATTACHED=$(aws ec2 describe-volumes --volume-ids $VOLUME_ID --query 'Volumes[0].Attachments' --output text)

if [[ $ATTACHED == "None" ]]; then
    echo "Attaching EBS Volume..."
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    aws ec2 attach-volume --volume-id $VOLUME_ID --instance-id $INSTANCE_ID --device $DEVICE_NAME
    sleep 10  # Wait for the volume to attach
fi

# Check if the volume is already formatted
if ! lsblk -f | grep -q "$DEVICE_NAME"; then
    echo "Formatting EBS Volume..."
    sudo mkfs -t ext4 $DEVICE_NAME
fi

# Mount the volume
mkdir -p $MOUNT_POINT
mount $DEVICE_NAME $MOUNT_POINT
echo "$DEVICE_NAME $MOUNT_POINT ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Set Ollama models directory
export OLLAMA_MODELS_DIR=$MOUNT_POINT
echo "export OLLAMA_MODELS_DIR=$MOUNT_POINT" >> ~/.bashrc
echo "EBS Volume is ready at $MOUNT_POINT"

#!/bin/bash

# Variables
S3_BUCKET="your-bucket-name"
MODEL_DIR="/mnt/ollama-models"

# Ensure AWS CLI is configured
if ! aws s3 ls "s3://$S3_BUCKET" &>/dev/null; then
    echo "AWS S3 not accessible. Check your credentials."
    exit 1
fi

# Create local directory
mkdir -p $MODEL_DIR

# Sync models from S3 to local
aws s3 sync s3://$S3_BUCKET/ollama-models/ $MODEL_DIR

# Set Ollama models directory
export OLLAMA_MODELS_DIR=$MODEL_DIR
echo "export OLLAMA_MODELS_DIR=$MODEL_DIR" >> ~/.bashrc

# Function to sync back to S3 before shutdown
sync_models_to_s3() {
    echo "Syncing models to S3..."
    aws s3 sync $MODEL_DIR s3://$S3_BUCKET/ollama-models/
}
trap sync_models_to_s3 EXIT

echo "S3 models synced. Ollama is ready."

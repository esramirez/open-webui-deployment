# Script for Managing Persistent Data with EBS and S3
A. Bash Script for EBS Persistence

This script will:

    Create an EBS volume if it doesn’t exist
    Attach and mount it to an EC2 instance
    Ensure models are stored persistently


# setmeup_s3.sh

Bash Script for S3 Persistence

This script will:

    Sync models from S3 to a local directory
    Store new models back to S3 for persistence
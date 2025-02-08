provider "aws" {
  region = var.aws_region
}

resource "aws_spot_instance_request" "ollama_spot" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"  # Replace with a valid GPU AMI
  instance_type = "g4dn.xlarge"
  spot_price    = "0.20"  # Adjust based on Spot pricing

  root_block_device {
    volume_size = 30  # Adjust disk size as needed
  }
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.dev_sg.id]
  tags = {
    Name = "dev_instance"    
    created_by  = "terraform"
    env         = "development"
    cost_center = "1234"
    delete_by   = "06012025"
  }

  user_data = <<EOF
#!/bin/bash
curl -fsSL https://ollama.com/install.sh | sh
aws s3 sync s3://your-bucket-name/ollama-models/ /mnt/ollama-models
export OLLAMA_MODELS_DIR=/mnt/ollama-models
echo "export OLLAMA_MODELS_DIR=/mnt/ollama-models" >> /home/ubuntu/.bashrc
EOF

  tags = {
    Name = "Ollama-Spot-Instance"
  }
}

resource "aws_ebs_volume" "ollama_ebs" {
  availability_zone = "us-east-1a"
  size             = 50
  type             = "gp3"
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.ollama_ebs.id
  instance_id = aws_spot_instance_request.ollama_spot.spot_instance_id
}


resource "aws_instance" "dev_instance" {
  ami           = "ami-04b4f1a9cf54c11d0" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.dev_sg.id]

  tags = {
    Name = "dev_instance"    
    created_by  = "terraform"
    env         = "development"
    cost_center = "1234"
    delete_by   = "06012025"
  }
}

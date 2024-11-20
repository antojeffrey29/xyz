terraform {
  backend "s3" {
    bucket         = "tfstatebuc"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
  /*required_version = ">=0.13.0"
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
  }*/
}

provider "aws" {
  region = "us-east-1" # Replace with your desired AWS region
}

resource "aws_instance" "free_tier_instance" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (Free Tier Eligible in us-east-1)
  instance_type = "t2.micro"             # Free-tier eligible instance type

  tags = {
    Name = "Trial Instance"
  }

  # Optional: Add security group to allow SSH (port 22)
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  # Optional: User data script to configure instance on launch
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > /var/www/html/index.html
              EOF
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere. Restrict in production.
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
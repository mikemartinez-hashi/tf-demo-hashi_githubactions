terraform {
  required_version = "~> 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # HCP Terraform remote backend
  # Replace YOUR_ORG_NAME with your HCP Terraform org
  cloud {
    organization = "YOUR_ORG_NAME"

    workspaces {
      name = "tf-demo-hashi"
    }
  }
}

provider "aws" {
  region = var.region
}

# -----------------------------------------------
# EC2 Web Server
# -----------------------------------------------
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.allow_http.id]

  user_data = templatefile("${path.module}/user_data.sh", {
    environment   = var.environment
    region        = var.region
    instance_type = var.instance_type
  })

  root_block_device {
    encrypted   = true
    volume_size = 20
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name        = "${var.server}-${var.environment}"
    Type        = var.demo
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------
# AMI - Amazon Linux 2023 (public, no account restriction)
# -----------------------------------------------
# Get AMI ID
data "aws_ami" "hc-base-ubuntu-2404" {
  for_each = toset(["amd64", "arm64"])
  filter {
    name   = "name"
    values = [format("hc-base-ubuntu-2404-%s-*", each.value)]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  most_recent = true
  owners      = ["888995627335"] # ami-prod account
}

# -----------------------------------------------
# Security Group
# -----------------------------------------------
resource "aws_security_group" "allow_http" {
  name        = "allow-http-${var.environment}"
  description = "Allow HTTP and HTTPS inbound for demo web server"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow-http-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

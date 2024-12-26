
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

variable "subnet_id" {}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_security_group" "subnet_security_group" {
  name        = "practice-server-sg"
  description = "Practice Security Group by Vinh"
  vpc_id      = data.aws_subnet.selected.vpc_id

  # ingress {
  #   description = "HTTPS Ingress"
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  #   egress {
  #     from_port   = 0
  #     to_port     = 0
  #     protocol    = -1
  #     cidr_blocks = ["0.0.0.0/0"]
  #   }
}

resource "aws_instance" "practice_app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3a.nano"
  key_name      = aws_key_pair.practice_vinh_key.key_name

  tags = {
    Name = "PracticeAppServer"
  }

  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.subnet_security_group.id]

}

output "instance_public_dns" {
  value = aws_instance.practice_app_server.public_dns
}

resource "aws_key_pair" "practice_vinh_key" {
  key_name   = "vinh-practice"
  public_key = file("~/.ssh/vinh-practice.pub")
}

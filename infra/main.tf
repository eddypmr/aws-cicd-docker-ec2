terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.0"
    }
  }
}


provider "aws" {
  region = "eu-west-1"
}

locals {
  name = "eddy-p2"
} 

# AMI Amazon Linux 2023

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
} 

# VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "${local.name}-vpc"
  }
}


resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
  tags = {
    Name = "${local.name}-subnet-public"
  }  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.name}-igw"
  }
}

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.name}-rt-public"
  }
}

resource "aws_route_table_association" "rta_public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.rt_public.id
}


# Grupo de seguridad

resource "aws_security_group" "sg" {
  name   = "${local.name}-sg"  
  vpc_id = aws_vpc.vpc.id

  # SSH abierto para que Github Actions pueda entrar
  ingress {
    description = "SSH temporalmente abierto"   
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Web app
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-sg"
  }
}

# Configuramos key pair

resource "aws_key_pair" "key" {
  key_name   = "${local.name}-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}



# EC2 con Docker instalado

resource "aws_instance" "ec2" {
  ami                        = data.aws_ssm_parameter.ami.value
  instance_type              = "t3.micro"
  subnet_id                  = aws_subnet.public.id
  vpc_security_group_ids     = [aws_security_group.sg.id]
  key_name                   = aws_key_pair.key.id
  associate_public_ip_address = true


  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y docker git
              systemctl enable docker
              systemctl start docker
              usermode -aG docker ec2-user
              EOF

  tags = {
    Name = "${local.name}-ec2"
  }
}

output "public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ssh_comand" {
  value = "ssh ec2-user@${aws_instance.ec2.public_ip}"
}

output "web_url" {
  value = "http://${aws_instance.ec2.public_ip}"
}



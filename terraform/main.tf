terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.42.0"
    }
  }

  required_version = ">= 1.7.5"
}

provider "aws" {
  region  = "us-east-1"
}

# Utworzenie VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main-vpc"
  }
}

# Utworzenie podsieci wewnatrz VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "subnet"
  }
}

# Utworzenie bramy internetowej
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gateway"
  }
}

# Tablica trasowania
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "this" {
  route_table_id = aws_route_table.route_table.id
  subnet_id = aws_subnet.subnet.id
}

# Grupa bezpieczenstwa
resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  # Reguly przychodzacego ruchu
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reguly wychodzacego ruchu
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "security_group"
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${path.module}/myKey.pem"
  content  = tls_private_key.pk.private_key_pem
}

# Zapisanie adresu IP instancji do pliku
resource "local_file" "instance_ip" {
  filename = "${path.module}/instance_ip.txt"
  content  = aws_instance.tic_tac_toe_server.public_ip
}

# Utworzenie instancji EC2
resource "aws_instance" "tic_tac_toe_server" {
  ami = "ami-0c101f26f147fa7fd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id     = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  key_name = aws_key_pair.kp.key_name
  user_data = file("${path.module}/install_docker.sh")
  user_data_replace_on_change = true
  tags = {
    Name = "tic_tac_toe"
  }
}
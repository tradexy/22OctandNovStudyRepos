#-------------------------------
# AWS Provider
#-------------------------------
provider "aws" {
  region = var.aws_region
}

#-------------------------------
# VPC resource
#-------------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    "Environment" = var.environment_tag
    "Name" = var.name_tag
  }
  enable_dns_support = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Environment" = var.environment_tag
    "Name" = var.name_tag
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidr_block)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.public_subnet_cidr_block, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = {
    "Environment" = "var.environment_tag"
  }
}

# Public Route Table and Association
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Environment" = "var.environment_tag"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(aws_subnet.public_subnet.*.id)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table.id
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_host" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = var.ingressfromport
    to_port   = var.ingresstoport
    protocol  = var.protocol
    // replace with your IP address, or CIDR block
    cidr_blocks = [var.IpAddress]
  }
  egress {
    from_port = var.egressfromport
    to_port   = var.egresstoport
    protocol  = "var.protocol"
  }
}

# Keypair
resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_host_key" {
  key_name   = var.key_name
  public_key = tls_private_key.public_key.public_key_openssh
}

# Bastion host EC2 instance
resource "aws_instance" "bastion_host" {
  ami           = var.ec2_ami
  instance_type = var.ec2_type
  key_name      = aws_key_pair.bastion_host_key.key_name
  vpc_security_group_ids      = [aws_security_group.bastion_host.id]
  subnet_id                   = element(aws_subnet.public_subnet.*.id, 1)
  associate_public_ip_address = true
}

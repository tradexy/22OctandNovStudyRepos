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
  profile    = "default"
  region  = "eu-west-1"
}

#existing repo found.

locals {
  stack_name = "my_template"
}

variable "vpccidr" {
  description = "IP Address range for the VPN connected VPC"
  type = string
  default = "10.1.0.0/16"
}

variable "subnet_cidr" {
  description = "IP Address range for the VPN connected Subnet"
  type = string
  default = "10.1.0.0/24"
}

variable "vpn_address" {
  description = "IP Address of your VPN device"
  type = string
}

variable "on_premise_cidr" {
  description = "IP Address range for your existing infrastructure"
  type = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "vpc" {
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  cidr_block = var.vpccidr
  tags = [
    {
      Key = "Application"
      Value = local.stack_name
    },
    {
      Key = "Network"
      Value = "VPN Connected VPC"
    }
  ]
}

resource "aws_ec2_subnet_cidr_reservation" "private_subnet" {
  subnet_id = aws_vpc.vpc.arn
  cidr_block = var.subnet_cidr
  // CF Property(Tags) = [
  //   {
  //     Key = "Application"
  //     Value = local.stack_name
  //   },
  //   {
  //     Key = "Network"
  //     Value = "VPN Connected Subnet"
  //   }
  // ]
}

resource "aws_vpn_gateway" "vpn_gateway" {
  // CF Property(Type) = "ipsec.1"
  tags = [
    {
      Key = "Application"
      Value = local.stack_name
    }
  ]
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpn_gateway_attachment" {
  vpc_id = aws_vpn_gateway.vpn_gateway.arn
}

resource "aws_customer_gateway" "customer_gateway" {
  type = "ipsec.1"
  bgp_asn = "65000"
  ip_address = var.vpn_address
  tags = [
    {
      Key = "Application"
      Value = local.stack_name
    },
    {
      Key = "VPN"
      Value = join("", ["Gateway to ", var.vpn_address])
    }
  ]
}

resource "aws_vpn_connection" "vpn_connection" {
  type = "ipsec.1"
  static_routes_only = "true"
  customer_gateway_id = aws_customer_gateway.customer_gateway.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gateway.arn
}

resource "aws_vpn_connection_route" "vpn_connection_route" {
  vpn_connection_id = aws_vpn_connection.vpn_connection.arn
  destination_cidr_block = var.on_premise_cidr
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.arn
  tags = [
    {
      Key = "Application"
      Value = local.stack_name
    },
    {
      Key = "Network"
      Value = "VPN Connected Subnet"
    }
  ]
}

resource "aws_route_table_association" "private_subnet_route_table_association" {
  subnet_id = aws_ec2_subnet_cidr_reservation.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route" "private_route" {
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_vpn_gateway.vpn_gateway.arn
}

resource "aws_network_acl" "private_network_acl" {
  vpc_id = aws_vpc.vpc.arn
  tags = [
    {
      Key = "Application"
      Value = local.stack_name
    },
    {
      Key = "Network"
      Value = "Private"
    }
  ]
}

resource "aws_network_acl" "inbound_private_network_acl_entry" {
  vpc_id = aws_network_acl.private_network_acl.id
  // CF Property(RuleNumber) = "100"
  // CF Property(Protocol) = "6"
  // CF Property(RuleAction) = "allow"
  egress = "false"
  // CF Property(CidrBlock) = "0.0.0.0/0"
  // CF Property(PortRange) = {
  //   From = "0"
  //   To = "65535"
  // }
}

resource "aws_network_acl" "out_bound_private_network_acl_entry" {
  vpc_id = aws_network_acl.private_network_acl.id
  // CF Property(RuleNumber) = "100"
  // CF Property(Protocol) = "6"
  // CF Property(RuleAction) = "allow"
  egress = "true"
  // CF Property(CidrBlock) = "0.0.0.0/0"
  // CF Property(PortRange) = {
  //   From = "0"
  //   To = "65535"
  // }
}

resource "aws_network_acl_association" "private_subnet_network_acl_association" {
  subnet_id = aws_ec2_subnet_cidr_reservation.private_subnet.id
  network_acl_id = aws_network_acl.private_network_acl.id
}

output "vpc_id" {
  description = "VPCId of the newly created VPC"
  value = aws_vpc.vpc.arn
}

output "private_subnet" {
  description = "SubnetId of the VPN connected subnet"
  value = aws_ec2_subnet_cidr_reservation.private_subnet.id
}

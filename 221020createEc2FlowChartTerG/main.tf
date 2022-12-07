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

# comment line: if default vpc required, then unhide below apart from comment line
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
# comment - line: force destroy line below does not work if required delete vpc manually
    force_destroy = true
  }
 }

resource "aws_instance" "app_server" {
  ami           = "ami-0ee415e1b8b71305f"
#  ami           = "ami-0648ea225c13e0729"
  instance_type = "t2.micro"

  tags = {
    Name = "create Ec2 and vpc look chart"
  }
}

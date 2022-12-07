terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.37.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "eu-west-1"
#    default_tags {
#    tags = {
#      Environment = "Test"
#      Owner       = "Find"
#    }
#  }
}
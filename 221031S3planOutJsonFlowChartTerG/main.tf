// completed
// quick tutorial to create s3. 1. providers. 2. main.tf terrafrom deploy, can then uncomment 4 lines to enable versioning
// as per https://www.youtube.com/watch?v=zMEaEMPzOws


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
  region = "us-east-2"
}

resource "aws_s3_bucket" "b" {
  bucket = "terraform221102jm"

//  versioning {
//    enabled = true
//  }

  tags = {
    Name        = "terraform"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}
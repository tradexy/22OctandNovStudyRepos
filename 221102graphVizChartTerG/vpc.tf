resource "aws_default_vpc" "default" {
  tags = {
    Name = "JMDefault VPC"
    force_destroy = true
  }
}
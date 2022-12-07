provider "aws" {

  region = "us-east-1"

}

# Keypair
resource "tls_private_key" "public_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "bastion_host_key" {
  key_name   = "tf_cf_keypair"
  public_key = tls_private_key.public_key.public_key_openssh
}

resource "aws_cloudformation_stack"  "tf_cf_vpc" {

 name = "TfCfVpc"

  parameters = {

   KeyName = "tf_cf_keypair"
    
#   InstanceType = "t2.micro"

}

 template_body = file("vpc.yaml")


}

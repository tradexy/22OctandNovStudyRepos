# myInfra2021Repo
azureDevOpsTerraformAWS

followed
https://www.coachdevops.com/2021/12/azure-devops-terraform-integration-how.html

git clone https://github.com/tradexy/myInfra2021Repo.git

here use eu-west-1 (ireland instead of Ohio)
created VPC first and follow tutorial
updated the github repo

--------
on azdo installed terraform extension https://skundunotes.com/2021/02/14/azure-devops-and-terraform-to-provision-aws-s3/
and also https://marketplace.visualstudio.com/items?itemName=charleszipp.azure-pipelines-tasks-terraform
--------

made changes to the region and bucket name:
terraform {
  backend "s3" {
    bucket = "mydev-tf-state-bucket-221205"
    key = "main"
    region = "eu-west-1"
    dynamodb_table = "my-dynamodb-table"
  }
}


-----
resource "aws_instance" "mySonarInstance" {
      ami           = "ami-0b9064170e32bde34"

and

changed ami (ubuntu ohio to ireland)
variable "ami_id" { 
    description = "AMI for Ubuntu Ec2 instance" 
    default     = "ami-020db2c14939a8efb" 

to:
ami-05e786af422f8082a

terraform {
  backend "s3" {
    bucket = "mydev-tf-state-bucket-221205"
    key = "main"
    region = "eu-west-1"
    dynamodb_table = "my-dynamodb-table"
  }
}

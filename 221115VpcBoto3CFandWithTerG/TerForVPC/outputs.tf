
output "cidr_block" {
  description = "cidr_block of VPC"
  value       = var.vpc_cidr_block
}

output "tags" {
  description = "tags of all resources"
  value       = {
    "Environment" = var.environment_tag
  }
}

output "gateway_id" {
  description = "id of internet gateway"
  value       = aws_internet_gateway.igw.id
}

output "subnet_id" {
  description = "subnet id of public subnet"
  value       = element(aws_subnet.public_subnet.*.id, 1)
}

output "route_table_id" {
  description = "route table id of public subnet"
  value       = aws_route_table.public_route_table.id
}

output "key_name" {
  description = "key pair name"
  value       = aws_key_pair.bastion_host_key.key_name
}

output "vpc_security_group_ids" {
  description = "id of security group"
  value       = [aws_security_group.bastion_host.id]
}
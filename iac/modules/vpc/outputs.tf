# Generated by Tofuinit

output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.this.id
}

output "subnet_ids" {
  description = "List of IDs for the created subnets"
  value       = aws_subnet.this.*.id
}

output "cidr_block" {
  description = "The ID of the created VPC"
  value       = aws_vpc.this.cidr_block
}


output "igw" {
  description = "The ID of the Internet "
  value       = aws_internet_gateway.this.id
}



# Import and use the VPC module to create a VPC
module "vpc" {
  source         = "./modules/vpc"    # Path to the VPC module
  region         = var.region         # AWS region for the VPC
  cidr_block_vpc = var.cidr_block_vpc # CIDR block for the VPC
  tgw_enabled    = var.tgw_enabled
}

# Import and use the EC2 module to create an EC2 instance
module "ec2" {
  source             = "./modules/ec2"       # Path to the EC2 module
  region             = var.region            # AWS region for the EC2 instance
  subnet_ids         = module.vpc.subnet_ids # Subnet IDs from the VPC module
  vpc_id             = module.vpc.vpc_id     # VPC ID from the VPC module
  cidr_block_vpc     = var.cidr_block_vpc
  cidr_block_vpc_tgw = var.cidr_block_vpc_tgw
  policy_arns        = var.policy_arns
}

variable "tgw_enabled" {}

variable "cidr_block_vpc_tgw" {}

variable "policy_arns" {}

# Output the VPC ID created by the VPC module
output "vpc_id" {
  value = module.vpc.vpc_id
}


# Output the Subnet IDs created by the VPC module
output "subnet_ids" {
  value = module.vpc.subnet_ids
}

# Output the CIDR block of the VPC created by the VPC module
output "cidr_block" {
  description = "The ID of the created VPC" # Description for the output
  value       = module.vpc.cidr_block
}

output "igw" {
  description = "The ID of the igw" # Description for the output
  value       = module.vpc.igw
}

# Output the Subnet IDs created by the VPC module
output "ec2_private_ips" {
  value = module.ec2.ec2_private_ips
}


# Declare a variable for AWS region
variable "region" {}

# Declare a variable for the VPC CIDR block
variable "cidr_block_vpc" {}




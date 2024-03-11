

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


module "region1" {
  source             = "../iac/"
  region             = var.region1
  cidr_block_vpc     = var.cidr_block_vpc_1
  cidr_block_vpc_tgw = var.cidr_block_vpc_2
  policy_arns        = var.policy_arns
  tgw_enabled        = var.tgw_enabled
}


module "region2" {
  source             = "../iac/"
  region             = var.region2
  cidr_block_vpc     = var.cidr_block_vpc_2
  cidr_block_vpc_tgw = var.cidr_block_vpc_1
  policy_arns        = var.policy_arns
  tgw_enabled        = var.tgw_enabled
}











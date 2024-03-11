
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "tgw" {
  source  = "../iac/modules/tgw/"
  region1 = var.region1
  region2 = var.region2
}







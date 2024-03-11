
# AWS provider configuration for region 1
provider "aws" {
  region = var.region1
  alias  = "region1"
}

# AWS provider configuration for region2 
provider "aws" {
  region = var.region2
  alias  = "region2"
}

# Create transit gateway in region1
resource "aws_ec2_transit_gateway" "region1" {
  provider = aws.region1

  tags = {
    Name = "${var.region1}-tgw"
  }
}

# Create transit gateway in region2
resource "aws_ec2_transit_gateway" "region2" {
  provider = aws.region2

  tags = {
    Name = "${var.region2}-tgw"
  }
}

# Create the TGW Peering attachment request in region2
resource "aws_ec2_transit_gateway_peering_attachment" "requester" {
  provider                = aws.region2
  peer_region             = var.region1
  peer_transit_gateway_id = aws_ec2_transit_gateway.region1.id
  transit_gateway_id      = aws_ec2_transit_gateway.region2.id

  tags = {
    Name = "tgw-peering-requestor"
    Side = "Requestor"
  }
}

# Load the TGW peering attachment request for acceptance in region1
data "aws_ec2_transit_gateway_peering_attachment" "accepter" {
  provider = aws.region1
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region1.id]
  }

  depends_on = [
    aws_ec2_transit_gateway_peering_attachment.requester
  ]
}


# Accept the TGW Peering attachment request in region1
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "this" {
  provider                      = aws.region1
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.accepter.id

  tags = {
    Name = "cross-region-attachment"
    Side = "Accepter"
  }
}

# Retrieve state information from the local Terraform state backend
data "terraform_remote_state" "state" {
  backend = "local"
  config = {
    path = "../vpc_ec2/terraform.tfstate"
  }
}

# Attach region1 VPC to TGW in region1
resource "aws_ec2_transit_gateway_vpc_attachment" "region1" {
  provider           = aws.region1
  subnet_ids         = data.terraform_remote_state.state.outputs.subnet_ids_region1[*]
  transit_gateway_id = aws_ec2_transit_gateway.region1.id
  vpc_id             = data.terraform_remote_state.state.outputs.vpc_id_region1
}

# Attach region2 VPC to TGW in region2
resource "aws_ec2_transit_gateway_vpc_attachment" "region2" {
  provider           = aws.region2
  subnet_ids         = data.terraform_remote_state.state.outputs.subnet_ids_region2[*]
  transit_gateway_id = aws_ec2_transit_gateway.region2.id
  vpc_id             = data.terraform_remote_state.state.outputs.vpc_id_region2
}

# Load TGW route table in region1
data "aws_ec2_transit_gateway_route_table" "region1" {
  provider = aws.region1
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region1.id]
  }
}

# Add route for region2 VPC via peering attachment in the region1 TGW route table 
resource "aws_ec2_transit_gateway_route" "region1" {
  provider                       = aws.region1
  destination_cidr_block         = data.terraform_remote_state.state.outputs.cidr_block_region2
  transit_gateway_attachment_id  = data.aws_ec2_transit_gateway_peering_attachment.accepter.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region1.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}


# Load TGW route table in region2
data "aws_ec2_transit_gateway_route_table" "region2" {
  provider = aws.region2
  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.region2.id]
  }
}

# Add route for region1 VPC via peering attachment in the region2 TGW route table 
resource "aws_ec2_transit_gateway_route" "region2" {
  provider                       = aws.region2
  destination_cidr_block         = data.terraform_remote_state.state.outputs.cidr_block_region1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.requester.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region2.id
  depends_on = [
    aws_ec2_transit_gateway_peering_attachment_accepter.this
  ]
}

# Load route table for region1 private subnet
data "aws_route_table" "region1_private" {
  provider = aws.region1
  vpc_id   = data.terraform_remote_state.state.outputs.vpc_id_region1
  tags = {
    Name = "Labs"
  }
}

# Create a new route entry in region1 private route table to route to region2 VPC via TGW
resource "aws_route" "region1_private_route" {
  provider               = aws.region1
  route_table_id         = data.aws_route_table.region1_private.id
  transit_gateway_id     = aws_ec2_transit_gateway.region1.id
  destination_cidr_block = data.terraform_remote_state.state.outputs.cidr_block_region2
}

# Load route table for region2 private subnet
data "aws_route_table" "region2_private" {
  provider = aws.region2
  vpc_id   = data.terraform_remote_state.state.outputs.vpc_id_region2
  tags = {
    Name = "Labs"
  }
}

# Create a new route entry in region2 private route table to route to region1 VPC via TGW
resource "aws_route" "region2_private_route" {
  provider               = aws.region2
  route_table_id         = data.aws_route_table.region2_private.id
  transit_gateway_id     = aws_ec2_transit_gateway.region2.id
  destination_cidr_block = data.terraform_remote_state.state.outputs.cidr_block_region1
}


# Create a new route entry in region1 private route table to route to region2 VPC via TGW
resource "aws_route" "region1_public_route" {
  provider               = aws.region1
  route_table_id         = data.aws_route_table.region1_private.id
  gateway_id             = data.terraform_remote_state.state.outputs.igw_region1
  destination_cidr_block = "0.0.0.0/0"
}

# Create a new route entry in region1 private route table to route to region2 VPC via TGW
resource "aws_route" "region2_public_route" {
  provider               = aws.region2
  route_table_id         = data.aws_route_table.region2_private.id
  gateway_id             = data.terraform_remote_state.state.outputs.igw_region2
  destination_cidr_block = "0.0.0.0/0"
}

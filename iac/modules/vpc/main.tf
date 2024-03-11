# Generated by Tofuinit
resource "aws_vpc" "this" {
  cidr_block = var.cidr_block_vpc
  tags = {
    Name = "Labs-${var.region}"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Labs"
  }
}

locals {
  base_cidr_block = aws_vpc.this.cidr_block
  subnet_masks    = [24, 24, 24] # Adjust subnet mask as needed
}

resource "aws_subnet" "this" {
  count                   = length(local.subnet_masks)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.base_cidr_block, 8, count.index)
  availability_zone       = element(tolist(data.aws_availability_zones.available.names), count.index)
  map_public_ip_on_launch = true # Adjust based on your needs

  tags = {
    Name = "Labs-${count.index}"
  }
}

resource "aws_route_table_association" "this" {
  count          = length(local.subnet_masks)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this.id
}


resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Labs"
  }
}

resource "aws_route" "example_route" {
  count                  = var.tgw_enabled ? 0 : 1
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"                  # Example: Route for all traffic
  gateway_id             = aws_internet_gateway.this.id # Replace with your Internet Gateway ID or relevant target
}
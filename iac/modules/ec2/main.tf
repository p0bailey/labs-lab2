# Generated by Tofuinit
provider "aws" {
  region = var.region # Your desired AWS region
}

resource "random_integer" "subnet" {
  min = 0
  max = length(var.subnet_ids[*]) - 1
}

data "aws_ami" "ami_name" {
  most_recent = true
  owners      = [var.owners]

  filter {
    name   = "name"
    values = [var.ami_name]
  }
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ami_name.id
  instance_type = var.instance_type

  subnet_id              = tolist(var.subnet_ids[*])[random_integer.subnet.result]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.ec2.id]

  lifecycle {
    ignore_changes = [subnet_id]
  }

  tags = {
    Name = "${var.ec2_name}-${var.region}"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_assume_role" {
  name               = "EC2SSMRole${var.region}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}


resource "aws_iam_role_policy_attachment" "poweruser_attachment" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.ec2_assume_role.name
  policy_arn = each.value
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2Profile${var.region}"
  role = aws_iam_role.ec2_assume_role.name
}

resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "Example security group for EC2 instance"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ec2"
  }
}

resource "aws_security_group_rule" "example_sg_tgw_ingress" {
  count       = var.tgw_enabled ? 1 : 0
  type        = "ingress"
  from_port   = 0
  to_port     = 65535
  protocol    = "all"
  cidr_blocks = [var.cidr_block_vpc_tgw]

  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "example_sg_all_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "example_sg_all_ingress" {
  type        = "ingress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.ec2.id
}

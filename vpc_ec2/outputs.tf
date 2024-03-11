
output "vpc_id_region1" {
  value = module.region1.vpc_id
}

output "vpc_id_region2" {
  value = module.region2.vpc_id
}

output "subnet_ids_region1" {
  value = module.region1.subnet_ids
}

output "subnet_ids_region2" {
  value = module.region2.subnet_ids
}

output "cidr_block_region1" {
  value = module.region1.cidr_block
}

output "cidr_block_region2" {
  value = module.region2.cidr_block
}

output "igw_region1" {
  value = module.region1.igw
}

output "igw_region2" {
  value = module.region2.igw
}

output "ec2_private_ips_us" {
  value = module.region2.ec2_private_ips
}

output "ec2_private_ips_aus" {
  value = module.region1.ec2_private_ips
}

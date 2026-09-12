output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_eip_public_ip" {
  description = "Public IP address of the NAT Gateway Elastic IP"
  value       = module.vpc.nat_eip_public_ip
}
output "ec2_instance_id" {
  description = "ID of the EC2 web instance"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 web instance"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS name of the EC2 web instance"
  value       = aws_instance.web.public_dns
}

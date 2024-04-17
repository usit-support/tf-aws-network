output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "nat_eip" {
  value = aws_eip.eip
}

output "nsg_pub_ids" {
  value = [aws_security_group.nsg_pub.id]
}

output "nsg_priv_ids" {
  value = [aws_security_group.nsg_priv.id]
}

output "subnet_priv_ids" {
  value = [
    aws_subnet.subnet_priv_a.id,
    aws_subnet.subnet_priv_b.id
  ]
}

output "subnet_pub_ids" {
  value = [
    aws_subnet.subnet_pub_a.id,
    aws_subnet.subnet_pub_b.id
  ]
}
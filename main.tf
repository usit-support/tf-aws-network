# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc

# VPC - 10.${var.project_id}.x.0/16

# Sub Priv A - 10.${var.project_id}.1.0/24
# Sub Priv B - 10.${var.project_id}.2.0/24
# Sub Priv C -                      3
# Sub Priv D -                      4
# Sub Priv E -                      .
# Sub Priv F -                      .

# Sub Pub A - 10.${var.project_id}.11.0/24
# Sub Pub B - 10.${var.project_id}.12.0/24
# Sub Pub C -                      13
# Sub Pub D -                      14
# Sub Pub E -                      ..
# Sub Pub F -                      ..

resource "aws_vpc" "vpc" {
  cidr_block = "10.${var.project_id}.0.0/16"
  tags       = merge(var.tags, { Name = "vpc_${var.project_id}" })
}

# nat Subnet with Default Route to Internet Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet

resource "aws_subnet" "subnet_priv_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.${var.project_id}.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = merge(var.tags, { Name = "subnet_priv_a_${var.project_id}" })
}

resource "aws_subnet" "subnet_priv_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.${var.project_id}.2.0/24"
  availability_zone = "${var.aws_region}b"

  tags = merge(var.tags, { Name = "subnet_priv_b_${var.project_id}" })
}

resource "aws_subnet" "subnet_pub_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.project_id}.11.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "subnet_pub_a_${var.project_id}" })
}

resource "aws_subnet" "subnet_pub_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.${var.project_id}.12.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(var.tags, { Name = "subnet_pub_b_${var.project_id}" })
}

# Main Internal Gateway for VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "igw_${var.project_id}" })
}

resource "aws_eip" "eip" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "eip_${var.project_id}" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_pub_a.id
  tags          = merge(var.tags, { Name = "nat_${var.project_id}" })
}

resource "aws_security_group" "nsg_priv" {
  name        = "nsg_pri_${var.project_id}"
  description = "allow inbound traffic from vpc"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "all traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "nsg_priv_${var.project_id}" })
}

resource "aws_security_group" "nsg_pub" {
  name        = "nsg-pub-${var.project_id}"
  description = "allow inbound traffic from nat"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "all traffic from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "nsg_pub_${var.project_id}" })
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.nsg_pub.id
  description       = "allow ssh"

  from_port   = 22
  to_port     = 22
  cidr_ipv4   = "10.0.0.0/8"
  ip_protocol = "tcp"
}

resource "aws_route_table" "rtb_priv" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.tags, { Name = "rtb_priv_${var.project_id}" })
}

resource "aws_route_table" "rtb_pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, { Name = "rtb_pub_${var.project_id}" })
}

resource "aws_route_table_association" "rtba_priv_a" {
  subnet_id      = aws_subnet.subnet_priv_a.id
  route_table_id = aws_route_table.rtb_priv.id
}

resource "aws_route_table_association" "rtba_priv_b" {
  subnet_id      = aws_subnet.subnet_priv_b.id
  route_table_id = aws_route_table.rtb_priv.id
}

resource "aws_route_table_association" "rtba_pub_a" {
  subnet_id      = aws_subnet.subnet_pub_a.id
  route_table_id = aws_route_table.rtb_pub.id
}

resource "aws_route_table_association" "rtba_pub_b" {
  subnet_id      = aws_subnet.subnet_pub_b.id
  route_table_id = aws_route_table.rtb_pub.id
}
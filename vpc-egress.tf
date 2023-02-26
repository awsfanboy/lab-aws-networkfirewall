module "egress_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name    = "${local.name}-egress-vpc"
  cidr    = var.egress_vpc_cidr

  azs                          = ["${var.region}a"]
  create_database_subnet_group = false

  manage_default_route_table = true
  default_route_table_tags = {
    Name = "default_${local.name}_egress_vpc"
  }

}

# TGW Subnet
resource "aws_subnet" "egress_vpc_tgw_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.egress_vpc_tgw_subnet_cidr
  vpc_id                  = module.egress_vpc.vpc_id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}_egress_vpc_tgw_subnet"
  }
}

# IGW Subnet
resource "aws_subnet" "egress_vpc_igw_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.egress_vpc_igw_subnet_cidr
  vpc_id                  = module.egress_vpc.vpc_id
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name}_egress_vpc_igw_subnet"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = module.egress_vpc.vpc_id

  tags = {
    Name = "${local.name}_internet_gateway"
  }
}

# NAT gateway elastic IP
resource "aws_eip" "eip_nat_gateway" {
  vpc = true
  depends_on = [
    module.egress_vpc.igw_id
  ]

  tags = {
    Name = "${local.name}_eip_nat_gateway"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.egress_vpc_igw_subnet.id

  depends_on = [
    module.egress_vpc.igw_id
  ]

  tags = {
    Name = "${local.name}_nat_gateway"
  }
}

# Egress Internet Gateway Public route table
resource "aws_route_table" "egress_public_route_table" {
  vpc_id = module.egress_vpc.vpc_id

  #  route {
  #    cidr_block = "0.0.0.0/0"
  #    gateway_id = aws_internet_gateway.internet_gateway.id
  #  }

  tags = {
    Name = "${local.name}_egress_vpc_public_route_table"
  }
}

#Egress VPC Public Route Table Association
resource "aws_route_table_association" "egress_internet_gateway" {
  subnet_id      = aws_subnet.egress_vpc_igw_subnet.id
  route_table_id = aws_route_table.egress_public_route_table.id
}

#Egress VPC Public Route Table - Routes
resource "aws_route" "egress_igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
  route_table_id         = aws_route_table.egress_public_route_table.id
}

resource "aws_route" "transit_gateway" {
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = aws_route_table.egress_public_route_table.id
}

#Egress VPC Firewall Route Table
resource "aws_route_table" "egress_vpc_firewall_route_table" {
  vpc_id = module.egress_vpc.vpc_id

  tags = {
    Name = "${local.name}_egress_vpc_firewall_route_table"
  }
}

#Egress VPC Firewall Route Table Association
resource "aws_route_table_association" "egress_vpc_tgw_subnet" {
  subnet_id      = aws_subnet.egress_vpc_tgw_subnet.id
  route_table_id = aws_route_table.egress_vpc_firewall_route_table.id
}

#Egress VPC Firewall Route Table - Routes
resource "aws_route" "egress_vpc_firewall_route_nat_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
  route_table_id         = aws_route_table.egress_vpc_firewall_route_table.id
}

resource "aws_route" "egress_vpc_firewall_route_transit_gateway" {
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = aws_route_table.egress_vpc_firewall_route_table.id
}
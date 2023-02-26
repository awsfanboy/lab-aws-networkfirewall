module "inspection_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name    = "${local.name}-inspection-vpc"
  cidr    = var.inspection_vpc_cidr

  azs = ["${var.region}a"]

  create_database_subnet_group = false
  create_igw                   = false

  manage_default_route_table = true
  default_route_table_tags = {
    Name = "default_${local.name}_inspection_vpc"
  }

}

// TGW Subnet
resource "aws_subnet" "inspection_vpc_tgw_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.inspection_vpc_tgw_subnet_cidr
  vpc_id                  = module.inspection_vpc.vpc_id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}_tgw_subnet"
  }
}


// AWS Network Firewall Subnets
resource "aws_subnet" "inspection_vpc_firewall_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.inspection_vpc_firewall_subnet_cidr
  vpc_id                  = module.inspection_vpc.vpc_id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}_firewall_subnet"
  }
}

#Inspection VPC Inspection Route Table
resource "aws_route_table" "inspection_vpc_inspection_route_table" {
  vpc_id = module.inspection_vpc.vpc_id

  tags = {
    Name = "${local.name}_inspection_vpc_inspection_route_table"
  }
}

#Inspection VPC Inspection Route Table Association
resource "aws_route_table_association" "inspection_vpc_tgw_subnet" {
  subnet_id      = aws_subnet.inspection_vpc_tgw_subnet.id
  route_table_id = aws_route_table.inspection_vpc_inspection_route_table.id
}

#Inspection VPC Inspection Route Table - Routes
resource "aws_route" "nat_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.aws_network_firewall_endpoint_id[0]
  route_table_id         = aws_route_table.inspection_vpc_inspection_route_table.id
}

#Inspection VPC Firewall Route Table
resource "aws_route_table" "inspection_vpc_firewall_route_table" {
  vpc_id = module.inspection_vpc.vpc_id

  tags = {
    Name = "${local.name}_inspection_vpc_firewall_route_table"
  }
}

#Inspection VPC Firewall Route Table Association
resource "aws_route_table_association" "inspection_vpc_firewall_subnet" {
  subnet_id      = aws_subnet.inspection_vpc_firewall_subnet.id
  route_table_id = aws_route_table.inspection_vpc_firewall_route_table.id
}

#Inspection VPC Firewall Route Table - Routes
resource "aws_route" "inspection_vpc_firewall_route_nat_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = aws_route_table.inspection_vpc_firewall_route_table.id
}
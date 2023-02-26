module "app_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name    = "${local.name}-app-vpc"
  cidr    = var.app_vpc_cidr

  azs = ["${var.region}a"]

  create_database_subnet_group = false
  create_igw                   = false

  manage_default_route_table = true
  default_route_table_tags = {
    Name = "default_${local.name}_app_vpc"
  }

}

// TGW Subnet
resource "aws_subnet" "app_vpc_tgw_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.app_vpc_tgw_subnet_cidr
  vpc_id                  = module.app_vpc.vpc_id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}_app_vpc_tgw_subnet"
  }
}


// App Workload Subnets
resource "aws_subnet" "app_vpc_workload_subnet" {
  availability_zone       = "${var.region}a"
  cidr_block              = var.app_vpc_application_workload_subnet_cidr
  vpc_id                  = module.app_vpc.vpc_id
  map_public_ip_on_launch = false

  tags = {
    Name = "${local.name}_app_vpc_firewall_subnet"
  }
}

#App VPC Workload Route Table
resource "aws_route_table" "app_vpc_workload_route_table" {
  vpc_id = module.app_vpc.vpc_id

  tags = {
    Name = "${local.name}_inspection_vpc_firewall_route_table"
  }
}

#App VPC Workload Route Table Association
resource "aws_route_table_association" "app_vpc_workload_subnet" {
  subnet_id      = aws_subnet.app_vpc_workload_subnet.id
  route_table_id = aws_route_table.app_vpc_workload_route_table.id
}

#App VPC Workload Route Table - Routes
resource "aws_route" "app_vpc_workload_route_nat_gateway" {
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  route_table_id         = aws_route_table.app_vpc_workload_route_table.id
}
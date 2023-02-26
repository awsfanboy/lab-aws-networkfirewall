resource "aws_ec2_transit_gateway" "tgw" {
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description                     = "DevOpsWithZack - AWS Network Firewall Labs TGW"

  tags = {
    "Name" = "${local.name}-TGW"
  }
}

#TGW Inspection VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection_vpc" {
  appliance_mode_support = "enable"
  subnet_ids = [
    aws_subnet.inspection_vpc_tgw_subnet.id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = module.inspection_vpc.vpc_id
}

#TGW App VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "app_vpc" {
  subnet_ids = [
    aws_subnet.app_vpc_tgw_subnet.id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = module.app_vpc.vpc_id
}

#TGW Egress VPC attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "egress_vpc" {
  subnet_ids = [
    aws_subnet.egress_vpc_tgw_subnet.id
  ]

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = module.egress_vpc.vpc_id
}

#TGW Route Tables
resource "aws_ec2_transit_gateway_route_table" "firewall_route_table" {
  tags = {
    "Name" = "${local.name}-firewall-tgw-route-table"
  }
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}


resource "aws_ec2_transit_gateway_route_table" "inspection_route_table" {
  tags = {
    "Name" = "${local.name}-inspection-tgw-route-table"
  }
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
}

#Firewall Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "inspection_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_route_table.id
}

#Inspection Route Table Association

#App VPC
resource "aws_ec2_transit_gateway_route_table_association" "app_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

#Egress VPC
resource "aws_ec2_transit_gateway_route_table_association" "egress_vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

#TGW Route Table
resource "aws_ec2_transit_gateway_route" "inspection_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection_route_table.id
}

resource "aws_ec2_transit_gateway_route" "app_vpc" {
  destination_cidr_block         = var.app_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_route_table.id
}

resource "aws_ec2_transit_gateway_route" "egress_vpc" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.egress_vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.firewall_route_table.id
}

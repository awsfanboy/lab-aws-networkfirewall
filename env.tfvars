project     = "devops-with-zack-demo"
aws_profile = "dev"
region      = "us-east-1"
az_a        = "us-east-1a"
team        = "devops"
env         = "dev"

#Inspection VPC
inspection_vpc_cidr                 = "100.64.0.0/16"
inspection_vpc_tgw_subnet_cidr      = "100.64.144.0/20"
inspection_vpc_firewall_subnet_cidr = "100.64.128.0/20"

#App VPC
app_vpc_cidr                             = "10.1.0.0/16"
app_vpc_tgw_subnet_cidr                  = "10.1.128.0/20"
app_vpc_application_workload_subnet_cidr = "10.1.144.0/20"

#App VPC
egress_vpc_cidr            = "10.2.0.0/16"
egress_vpc_tgw_subnet_cidr = "10.2.128.0/20"
egress_vpc_igw_subnet_cidr = "10.2.144.0/20"

#SSH Key -
ssh_key = ""
variable "region" {
  description = "AWS region Eg: us-east-1"
  type        = string
  default     = ""
}

variable "project" {
  description = "Name of the project"
  default     = ""
}

###### VPC Variables ######

variable "aws_profile" {
  description = "Profile name of the AWS Account"
  type        = string
  default     = ""
}

variable "az_a" {
  description = "Availability Zone A"
  type        = string
  default     = ""
}

variable "team" {
  description = "name of the team eg: front-end, devops, database"
  type        = string
  default     = ""
}

variable "env" {
  description = "name of the environment eg: development, uat, staging, production"
  type        = string
  default     = ""
}

variable "public_subnet_a" {
  type    = string
  default = ""
}

variable "public_subnet_b" {
  type    = string
  default = ""

}

#Inspection VCP
variable "inspection_vpc_cidr" {
  description = "CIDR range of the inspection vpc"
  type        = string
  default     = ""
}

variable "inspection_vpc_tgw_subnet_cidr" {
  type    = string
  default = ""
}

variable "inspection_vpc_firewall_subnet_cidr" {
  type    = string
  default = ""
}

#App VPC
variable "app_vpc_cidr" {
  description = "CIDR range of the app vpc"
  type        = string
  default     = ""
}

variable "app_vpc_tgw_subnet_cidr" {
  type    = string
  default = ""
}

variable "app_vpc_application_workload_subnet_cidr" {
  type    = string
  default = ""
}

#Egress VPC
variable "egress_vpc_cidr" {
  description = "CIDR range of the egress vpc"
  type        = string
  default     = ""
}

variable "egress_vpc_tgw_subnet_cidr" {
  type    = string
  default = ""
}

variable "egress_vpc_igw_subnet_cidr" {
  type    = string
  default = ""
}

#SSK Key
variable "ssh_key" {
  type = string
  default = ""
}
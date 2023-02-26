#SSH key
resource "aws_key_pair" "ssh_key_aws_nfw_lab" {
  key_name   = "ssh_key_aws_nfw_lab_devops_with_zack"
  public_key = var.ssh_key
}

#App server EC2 instance
module "app_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "app-ec2"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.ssh_key_aws_nfw_lab.key_name
  vpc_security_group_ids = [aws_security_group.allow_from_egress_vpc_ssh.id]
  subnet_id              = aws_subnet.app_vpc_workload_subnet.id

  tags = {
    Environment = var.env
    Project     = var.project
    Team        = var.team
  }
}

#Bastion Host EC2 instance
module "bastion_host_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "bastion-host-ec2"

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.ssh_key_aws_nfw_lab.key_name
  vpc_security_group_ids      = [aws_security_group.allow_public_ssh.id]
  subnet_id                   = aws_subnet.egress_vpc_igw_subnet.id
  associate_public_ip_address = true

  tags = {
    Environment = var.env
    Project     = var.project
    Team        = var.team
  }
}

#SSH from public
resource "aws_security_group" "allow_public_ssh" {
  name        = "allow_public_ssh"
  description = "Allow Public SSH inbound traffic"
  vpc_id      = module.egress_vpc.vpc_id

  ingress {
    description = "SSH Access From Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_public_ssh"
  }
}

#SSH from egress vpc
resource "aws_security_group" "allow_from_egress_vpc_ssh" {
  name        = "allow_from_egress_vpc_ssh"
  description = "Allow egress vpc to SSH inbound traffic"
  vpc_id      = module.app_vpc.vpc_id

  ingress {
    description = "SSH Access From Public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [module.egress_vpc.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_egress_vpc_to_ssh"
  }
}
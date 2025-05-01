data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["aws-elasticbeanstalk-amzn-2.0.20240223*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["964913206263"]

 
}


resource "aws_vpc" "custom_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.custom_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private"
  }
}


resource "aws_security_group" "allow_http_https" {
  name        = "allow_https/https"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  tags = {
    Name = "allow_http(s)"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = module.module_service_sg.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

module "module_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "module_service_group"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = "vpc-12345678"

  ingress_cidr_blocks      = ["10.10.0.0/16"]
  ingress_rules            = ["http=80-tcp","https-443-tcp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8090
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = "10.10.0.0/16"
    }
  ]
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "ssh-key"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKzUBT9HRDJYhhS6rS1cqlXug/Wnv33UZbQ4UIHombPH jaspal.singh@monash.edu"
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "terraform gateway"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id         = aws_vpc.custom_vpc.id
  route {
    cidr_block   = "0.0.0.0/0"
    gateway_id   = aws_internet_gateway.gw.id
  }
  tags           = {
    Name = "public_route_table"
  }
}


resource "aws_route_table_association" "associate_route_to_subnet" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}


resource "aws_instance" "web" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]
   subnet_id             = aws_subnet.public.id
   key_name              = aws_key_pair.ssh_key.id
  tags = {
    Name = "Terraform instance"
  }
}

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
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Main"
  }
}


resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.public.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
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
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_http_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]
  
  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }

  tags = {
    Name = "HelloWorld"
  }
}

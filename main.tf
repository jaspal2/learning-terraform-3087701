data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ami-0f6a1a6507c55c9a8"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

 
}


resource "aws_vpc" "custom_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
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

  tags = {
    Name = "HelloWorld"
  }
}

data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2023 AMI"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}

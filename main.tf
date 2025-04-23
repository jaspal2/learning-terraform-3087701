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

  owners = ["964913206263"] # AWS
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  tags = {
    Name = "HelloWorld"
  }
}

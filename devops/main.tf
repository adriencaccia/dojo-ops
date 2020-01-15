provider "aws" {
  profile = "user1"
  region  = "eu-west-1"
}

resource "aws_security_group" "security-group-1" {
  name        = "security-group-1"
  description = "My first security group"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "user1" {
  key_name   = "user1-key"
  public_key = file("~/.ssh/aws-test.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  availability_zone = "eu-west-1a"
  key_name          = aws_key_pair.user1.key_name
  ami               = data.aws_ami.ubuntu.id
  security_groups   = [aws_security_group.security-group-1.name]
  instance_type     = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}

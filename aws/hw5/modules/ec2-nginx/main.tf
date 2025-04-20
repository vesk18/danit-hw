variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "list_of_open_ports" {
  description = "List of ports to open in the security group"
  type        = list(number)
}

resource "aws_security_group" "allow_ports" {
  name        = "allow_ports_sg"
  description = "Allow access to specified ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.list_of_open_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

  availability_zone = "eu-central-1a"
}

resource "aws_instance" "public_ec2" {
  ami           = "ami-0d8d11821a1c1678b"  # Amazon Linux 2023 AMI
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnet.public.id
  security_groups = [aws_security_group.allow_ports.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF

  tags = {
    Name = "Public EC2 with Nginx"
  }
}

output "instance_ip" {
  value = aws_instance.public_ec2.public_ip
}


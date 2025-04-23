variable "vpc_id" {
  description = "ID of the VPC where resources will be created"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet to launch EC2 instance in"
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

resource "aws_instance" "public_ec2" {
  ami           = "ami-0d8d11821a1c1678b"  # Amazon Linux 2023
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
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

output "instance_ip" {
  value = aws_instance.public_ec2.public_ip
}


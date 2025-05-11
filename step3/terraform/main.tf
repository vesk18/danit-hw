provider "aws" {
  region = "us-east-1"
}

# S3 bucket
resource "aws_s3_bucket" "jenkins_state" {
  bucket = "step3-bucket-vesk18-unique"
  force_destroy = true
  tags = {
    Name = "Jenkins State Bucket"
  }
}

# SSH key
resource "aws_key_pair" "step3_key" {
  key_name   = "step3-key-vesk18"
  public_key = file("/Users/hugo/vs-code/step3/test1.pub") 
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "step3-vpc-vesk18"
  }
}

# IGW PUBLIC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "step3-igw-vesk18"
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  domain = "vpc"  # Use 'domain' instead of 'vpc'
}

# NAT
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_public.id
  tags = {
    Name = "step3-nat-gateway-vesk18"
  }
}

# Public Subnet for Master
resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "step3-subnet-public-vesk18"
  }
}

# Private Subnet for Worker
resource "aws_subnet" "subnet_private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "step3-subnet-private-vesk18"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "step3-route-table-public-vesk18"
  }
}

# Public Subnet for Route Table
resource "aws_route_table_association" "rta_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table_public.id
}

# Route Table for Private Subnet
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "step3-route-table-private-vesk18"
  }
}

# Private Subnet with Route Table
resource "aws_route_table_association" "rta_private" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.route_table_private.id
}

# Security Group for Jenkins EC2
resource "aws_security_group" "sg" {
  name        = "step3-sg-vesk18"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    Name = "step3-sg-vesk18"
  }
}

# Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Jenkins Master EC2
resource "aws_instance" "jenkins_master" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.step3_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "step3-jenkins-master-vesk18"
  }
}

# Jenkins Worker EC2
resource "aws_spot_instance_request" "jenkins_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_private.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.step3_key.key_name
  wait_for_fulfillment        = true
  spot_type                   = "one-time"
  tags = {
    Name = "step3-jenkins-worker-vesk18"
  }
}

output "master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "worker_private_ip" {
  value = aws_spot_instance_request.jenkins_worker.private_ip
}

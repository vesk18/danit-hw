
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "jenkins_state" {
  bucket = "step3-bucket-vesk18-unique"
  force_destroy = true
  tags = {
    Name = "Jenkins State Bucket"
  }
}



resource "aws_key_pair" "step3_key" {
  key_name   = "step3-key-vesk18"
  public_key = file("../test1.pub")
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "step3-vpc-vesk18"
  }
}

resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "step3-subnet-public-vesk18"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "step3-igw-vesk18"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "step3-route-table-vesk18"
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table.id
}

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

# Use Ubuntu 20.04 LTS AMI (us-east-1)
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Ubuntu's official account ID
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

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

resource "aws_instance" "jenkins_worker" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  key_name                    = aws_key_pair.step3_key.key_name
  associate_public_ip_address = true
  tags = {
    Name = "step3-jenkins-worker-vesk18"
  }
}

output "master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "worker_public_ip" {
  value = aws_instance.jenkins_worker.public_ip
}

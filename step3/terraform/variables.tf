variable "aws_region" {
  default = "us-east-1"
}

variable "public_key_path" {
  default = "../test1.pub"
}

variable "master_instance_type" {
  default = "t2.micro"
}

variable "worker_instance_type" {
  default = "t2.micro"
}

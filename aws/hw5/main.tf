provider "aws" {
  region = "eu-central-1"
}

variable "username" {
  type        = string
  description = "Your login name for backend path"
  default     = "vesk18"
}

module "ec2_nginx" {
  source             = "./modules/ec2-nginx"
  vpc_id             = "vpc-08027fb7ca8977cdd"
  list_of_open_ports = [80, 443]
}

output "instance_ip" {
  value = module.ec2_nginx.instance_ip
}


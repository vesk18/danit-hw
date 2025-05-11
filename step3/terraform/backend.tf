terraform {
  backend "s3" {
    bucket = "step3-bucket-vesk18-unique"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

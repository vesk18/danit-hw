terraform {
  backend "s3" {
    bucket = "vesk2412"
    key    = "hugo/terraform.tfstate"
    region = "eu-central-1"
    encrypt = true
  }
}

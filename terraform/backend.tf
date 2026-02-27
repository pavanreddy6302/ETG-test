terraform {
  backend "s3" {
    bucket      = "etg-test1"
    key         = "terraform.tfstate"
    region      = "us-east-1"  # Change this to your desired AWS region
  }
}

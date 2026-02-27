terraform {
  backend "s3" {
    bucket      = "hhc-terraform-backend-s3"
    key         = "terraform/cf/terraform.tfstate"
    region      = "ap-south-1"  # Change this to your desired AWS region
  }
}

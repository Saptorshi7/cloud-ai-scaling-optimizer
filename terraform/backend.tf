terraform {
  backend "s3" {
    bucket         = "spl-tf-bucket"
    key            = "cloud-ai-scaling-optimizer/terraform.tfstate"
    region         = "us-east-1"
  }
}
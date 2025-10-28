terraform {
  backend "s3" {
    bucket         = "spl-terraform"
    key            = "cloud-ai-scaling-optimizer/terraform.tfstate"
    region         = "us-east-1"
  }
}
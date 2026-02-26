terraform {
  backend "s3" {
    bucket         = "ibank-terraform-state"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ibank-terraform-locks"
    encrypt        = true
  }
}
terraform {
  backend "s3" {
    bucket         = "ibank-terraform-state-us-east-1"
    key            = "envs/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ibank-terraform-locks"
    encrypt        = true
  }
}
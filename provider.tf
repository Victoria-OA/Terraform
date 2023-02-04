#add provider with current version
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      #version = "~> 4.5"
    }
  }
}

#add provider block which provide information to access aws
provider "aws" {
  region                   = "us-east-2"
  shared_credentials_files = ["~/.aws/credentials"]

}


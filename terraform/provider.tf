terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "particle41-devops-tfstate-deepakyadav"  
    key            = "terraform/infra.tfstate"
    region         = "ap-south-1"                              
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}


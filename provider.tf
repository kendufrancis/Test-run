
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "2.70.0"
    }
  }

  # backend "s3" {
  #   bucket = "kendu237backend"
  #   key    = "state/terraform_state.tfstate"
  #   region = "eu-north-1"
  # }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

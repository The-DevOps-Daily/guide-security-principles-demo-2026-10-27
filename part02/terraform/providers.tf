# Not shown in the guide: just enough to run `terraform validate` on network.tf and waf.tf.
terraform {
  required_version = ">= 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.70"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC for the ticket shop"
}

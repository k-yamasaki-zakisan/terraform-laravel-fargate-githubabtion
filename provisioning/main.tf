terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.1.0"
    }
  }
}

locals {
  APP_NAME = "laravel-fargate"
  AWS_DEFAULT_REGION = "ap-northeast-1"
  HOST_DOMAIN = "spa-deploy-yamasaki.tk"
  APP_DOMAIN_NAME = "app.spa-deploy-yamasaki.tk"
}

provider "aws" {
  region = local.AWS_DEFAULT_REGION
  default_tags {
    tags = {
      application = local.APP_NAME
    }
  }
}
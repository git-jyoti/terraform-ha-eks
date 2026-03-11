terraform {
  backend "s3" {
    bucket         = "ha-eks-terraform-state-<ACCOUNT_ID>"
    key            = "global/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "ha-eks-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

module "global_accelerator" {
  source = "../modules/global_accelerator"

  project_name = "ha-eks-global"
  region_a     = "ap-south-1"
  region_b     = "ap-southeast-1"
  alb_arn_a    = "arn:aws:elasticloadbalancing:ap-south-1:XXXXXX:loadbalancer/app/ha-eks-mumbai-alb/XXXXXX" 
  alb_arn_b    = "arn:aws:elasticloadbalancing:ap-southeast-1:XXXXXX:loadbalancer/app/ha-eks-singapore-alb/XXXXXX"
}

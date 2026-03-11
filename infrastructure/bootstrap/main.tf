provider "aws" {
  region = "ap-south-1" # Bootstrap in Mumbai
}

module "terraform_state" {
  source = "../modules/terraform_state"

  bucket_name = "ha-eks-terraform-state-${data.aws_caller_identity.current.account_id}"
  table_name  = "ha-eks-terraform-locks"
}

data "aws_caller_identity" "current" {}

output "terraform_state_bucket" {
  value = module.terraform_state.bucket_name
}

output "terraform_locks_table" {
  value = module.terraform_state.table_name
}

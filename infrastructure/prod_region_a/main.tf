terraform {
  backend "s3" {
    bucket         = "ha-eks-terraform-state-592579839583"
    key            = "region-a/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "ha-eks-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.cluster_name]
    command     = "aws"
  }
}

locals {
  project_name = "ha-eks-mumbai"
  cluster_name = "prod-mumbai"
  vpc_cidr     = "10.1.0.0/16"
  region       = "ap-south-1"
  tags = {
    Environment = "prod"
    Region      = "ap-south-1"
  }
}

module "network" {
  source = "../modules/network"

  project_name       = local.project_name
  vpc_cidr           = local.vpc_cidr
  public_subnets     = ["10.1.1.0/24"]
  private_subnets    = ["10.1.10.0/24"]
  availability_zones = ["ap-south-1a"]
  cluster_name       = local.cluster_name
  tags               = local.tags
}

module "iam" {
  source = "../modules/iam"

  project_name = local.project_name
  tags         = local.tags
}

module "security" {
  source = "../modules/security"

  project_name = local.project_name
  vpc_id       = module.network.vpc_id
  cluster_name = local.cluster_name
  tags         = local.tags
}

module "eks_cluster" {
  source = "../modules/eks_cluster"

  cluster_name     = local.cluster_name
  cluster_role_arn = module.iam.cluster_role_arn
  subnet_ids       = module.network.private_subnet_ids
  cluster_sg_id    = module.security.cluster_sg_id
  kms_key_arn      = module.security.kms_key_arn
  tags             = local.tags
}

module "node_group" {
  source = "../modules/node_group"

  cluster_name  = module.eks_cluster.cluster_name
  node_role_arn = module.iam.node_role_arn
  subnet_ids    = module.network.private_subnet_ids
  tags          = local.tags
}

module "load_balancer" {
  source = "../modules/load_balancer"

  project_name      = local.project_name
  domain_name       = "my-eks-app.com"
  alb_sg_id         = module.security.node_sg_id # Simplified, should use dedicated ALB SG
  public_subnet_ids = module.network.public_subnet_ids
  tags              = local.tags
}


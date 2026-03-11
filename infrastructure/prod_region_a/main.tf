terraform {
  backend "s3" {
    bucket         = "ha-eks-terraform-state-<ACCOUNT_ID>"
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
  public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  private_subnets    = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"]
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
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

module "dns" {
  source = "../modules/dns"

  domain_name = "my-eks-app.com"
  subdomain   = "api"
  lb_dns_name = module.load_balancer.alb_dns_name
  lb_zone_id  = "Z1108A5E79EU0" # Example ALB Zone ID for ap-south-1
  region      = local.region
  tags        = local.tags
}

module "storage" {
  source = "../modules/storage"

  project_name = local.project_name
  kms_key_arn  = module.security.kms_key_arn
  subnet_ids   = module.network.private_subnet_ids
  efs_sg_id    = module.security.node_sg_id
  tags         = local.tags
}

module "logging" {
  source = "../modules/logging_monitoring"

  cluster_name = local.cluster_name
  tags         = local.tags
}

module "ha" {
  source = "../modules/multi_region_ha"

  region           = local.region
  cluster_endpoint = module.eks_cluster.cluster_endpoint
}

# Elite: Database Primary (Writer)
module "database" {
  source = "../modules/database"

  project_name      = local.project_name
  is_global_cluster = true
  db_name           = "production_db"
  
  db_subnet_group_name   = "main-subnet-group" # Needs to be created
  vpc_security_group_ids = [module.security.node_sg_id]
  instance_count         = 2
  tags                   = local.tags
}

# Elite: VPC Peering Request
module "peering_request" {
  source = "../modules/vpc_peering"

  project_name        = local.project_name
  vpc_id              = module.network.vpc_id
  peer_vpc_id         = "vpc-xxxxxxxx" # Replace with Region B VPC ID
  peer_region         = "ap-southeast-1"
  peer_vpc_cidr       = "10.2.0.0/16"
  vpc_route_table_ids = [module.network.vpc_id] # Simplified
  tags                = local.tags
}

# Elite: GitOps (ArgoCD)
module "gitops" {
  source = "../modules/gitops"
}

module "network_policies" {
  source = "../modules/network_policy"

  namespace    = "default"
  backend_port = 8080
  db_port      = 5432
}

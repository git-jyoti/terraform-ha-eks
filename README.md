# Walkthrough - Multi-Region High-Availability EKS Cluster (Modular)

I have successfully implemented a production-grade, modular Terraform infrastructure for an EKS cluster spanning two AWS regions: `ap-south-1` (Mumbai) and `ap-southeast-1` (Singapore).

## Project Structure

The project follows a granular modular design for maximum reusability and clarity:

```text
infrastructure/
├── bootstrap/             # Bootstraps the S3/DynamoDB remote state
├── modules/
│   ├── network/           # VPC, Subnets, NAT Gateways
│   ├── iam/               # Roles for Cluster, Nodes, and OIDC
│   ├── security/          # KMS keys and Security Groups
│   ├── eks_cluster/       # EKS Control Plane & OIDC Provider
│   ├── node_group/        # Managed Node Groups
│   ├── load_balancer/     # ALB and ACM Certificates
│   ├── dns/               # Route 53 with Latency-based routing
│   ├── logging_monitoring/# CloudWatch Logs for EKS
│   ├── storage/           # EFS for persistent storage
│   ├── multi_region_ha/   # SSM parameters and global logic
│   └── terraform_state/   # Shared state resources
├── prod_region_a/         # Configuration for ap-south-1
└── prod_region_b/         # Configuration for ap-southeast-1
```

## Key Features

- **Remote State Management**: Secure state storage using an S3 bucket (versioned/encrypted) and DynamoDB for state locking.
- **Granular Security**: Dedicated KMS keys for EKS secret encryption and strict micro-segmentation using Security Groups.
- **High Availability**: Multi-AZ VPC setup (3 AZs per region) with private subnets for EKS control plane and nodes.
- **Global Traffic Management**: Route 53 latency routing to direct users to the nearest healthy region via an API subdomain.
- **EFS Storage**: Shared storage capability for stateful Kubernetes workloads across availability zones.

## How to Deploy

### 1. Update Account ID
Search for `<ACCOUNT_ID>` in `infrastructure/prod_region_a/main.tf` and `infrastructure/prod_region_b/main.tf` and replace it with your actual AWS Account ID.

### 2. Bootstrap State
Navigate to the bootstrap directory and run:
```bash
cd infrastructure/bootstrap
terraform init
terraform apply
```
This will output the name of your new state bucket.

### 3. Deploy Regions
Deploy Mumbai (`prod_region_a`) first, then Singapore (`prod_region_b`):
```bash
cd ../prod_region_a
terraform init
terraform apply

cd ../prod_region_b
terraform init
terraform apply
```

## Verification

Once deployed, you can verify the status:
- **EKS**: Run `aws eks update-kubeconfig --region ap-south-1 --name prod-mumbai` and check nodes.
- **DNS**: Verify that `api.my-eks-app.com` resolves to the nearest ALB.
- **Backup**: Verify that state files are present in the S3 bucket under `region-a/` and `region-b/`.

# Walkthrough - Best-of-Best Multi-Region EKS (Modular & Connected)

I have implemented a world-class, "Best of Best" modular Terraform infrastructure for an EKS cluster spanning Mumbai (`ap-south-1`) and Singapore (`ap-southeast-1`).

## Connected Architecture Flow

```text
Users / Pods
      ↓
AWS Global Accelerator (Static IPs)
      ↓
Route 53 DNS (Global Endpoint)
      ↓
ALB Ingress (Regional Entry)
      ↓
EKS Clusters (Mumbai & Singapore)
      ↓
VPC Peering (Private Inter-region Backbone)
      ↓
Aurora Global Database (Primary/Replica Sync)
      ↓
GitOps (ArgoCD Synchronization)
```

## Project Structure

```text
infrastructure/
├── bootstrap/             # Bootstraps S3/DynamoDB Remote State
├── global/                # Global Accelerator (Unified Entry)
├── modules/
│   ├── network/           # VPC setup
│   ├── eks_cluster/       # EKS + VPC CNI Policy Support
│   ├── database/          # Aurora Global Database
│   ├── vpc_peering/       # Cross-region Private Link
│   ├── gitops/            # ArgoCD GitOps
│   └── (other modules)    # IAM, Security, DNS, Storage, Logging
├── prod_region_a/         # Mumbai (Primary Writer + Peering Request)
└── prod_region_b/         # Singapore (Secondary Reader + Peering Accept)
```

## How to Deploy (CONNECTED ORDER)

### 1. Bootstrap
Run `terraform apply` in `infrastructure/bootstrap`.

### 2. Mumbai (Region A)
Run `terraform apply` in `infrastructure/prod_region_a`. 
*This establishes the Primary DB and initiates the VPC Peering.*

### 3. Singapore (Region B)
Update the Peering ID and VPC ID from Mumbai's output into `prod_region_b/main.tf`, then run `terraform apply`.
*This accepts the Peering and creates the DB Replica.*

### 4. Global
Update ALB ARNs from both regions into `global/main.tf`, then run `terraform apply`.
*This creates the Global Accelerator "Traffic Brain" for the global entry.*

## Verification
- **GitOps**: Run `kubectl get pods -n argocd` in both clusters.
- **Peering**: Ping a private IP in Singapore from a Mumbai pod.
- **Global Entry**: Use the Global Accelerator DNS to reach the app.

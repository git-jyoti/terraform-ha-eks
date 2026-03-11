# Production-Grade Multi-Region EKS Cluster

This plan outlines the creation of a highly available EKS infrastructure spanning two AWS regions, with a focus on security, modularity, and scalability.

## User Review Required

> [!IMPORTANT]
> **Multi-Region Cluster Reality**: Standard AWS EKS clusters are regional. To achieve "multi-region nodes", we will deploy two independent EKS clusters (one in each region) and configure them consistently. Global orchestration (e.g., Global Accelerator or Cross-Region Mesh) would be the next step for application-level failover.

## Proposed Changes

### Project Structure
We will use a modular approach with a top-level `main.tf` calling regional modules. We will use `locals` to handle region-specific configurations (CIDRs, AZs).

### Networking Component
- **Multi-AZ VPCs**: 2 VPCs in an **Active-Active** configuration across two regions (e.g., us-east-1 and us-west-2), each with 3 Availability Zones.
- **Private Networking**: Nodes and Control Plane endpoints will be private. NAT Gateways for outbound traffic.
- **VPC Endpoints**: Interface endpoints for ECR, S3, STS, and EC2 to prevent data exfiltration.

### Security Component
- **IAM (IRSA)**: Enable OIDC providers for IAM Roles for Service Accounts (Least Privilege).
- **KMS**: Customer Managed Keys (CMKs) for EBS volume encryption, K8s Secret envelope encryption, and S3 backends.
- **Security Groups**: Micro-segmentation with strict ingress/egress for node-to-node and control-plane-to-node traffic.
- **Control Plane Logging**: API, Audit, Authenticator, Controller Manager, and Scheduler logs enabled.
- **Advanced Security**: Plan for AWS WAF (Web Application Firewall) on Load Balancers and GuardDuty EKS Protection.

### EKS & Scaling Component
- **Managed Node Groups**: For easier patching and lifecycle management.
- **Scaling (Karpenter)**: Ready for Karpenter or Cluster Autoscaler to handle node elasticity.
- **Pod Affinity**: Use `topologySpreadConstraints` to ensure application replicas are balanced across zones and regions.

### Global Traffic Management
- **Route 53 Latency Routing**: To route users to the nearest healthy region.
- **Health Checks**: DNS health checks to automatically failover if a region goes down.

## Verification Plan

### Automated Tests
- `terraform validate` and `terraform plan`.
- `checkov` or `tfsec` for static security analysis (Recommended for Production).

### Manual Verification
- Verify EKS clusters are active in both regions.
- Deploy a sample application and verify `topologySpreadConstraints`.
- Simulate a regional failover by updating Route 53 health records.

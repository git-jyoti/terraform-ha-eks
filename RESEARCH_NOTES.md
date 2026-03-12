# Research Notes: Multi-Account & Multi-App Terraform Architecture

## 1. Is it a valid question?
**Yes.** It is a classic question for **Cloud Architects** or **Platform Engineers**. It tests your ability to design a scalable, secure, and isolated infrastructure-as-code (IaC) environment.

## 2. Core Problem Breakdown
- **Multiple Accounts**: How do you manage resources across Account A (Production), Account B (Staging), and Account C (Shared Services)?
- **Variable App Access**: How do you ensure "Team Alpha" can only touch 5 apps, while "Team Admin" can touch all 10?

## 3. How to handle "Multiple Accounts" in Terraform
There are three main ways:

### A. Professional Directory Structure (Recommended)
You separate your infrastructure into folders. Each folder has its own `backend.tf` and `provider.tf`.
```text
infrastructure/
├── bootstrap/ (S3/DynamoDB for state)
├── apps/
│   ├── app-01/
│   │   ├── production/ (Points to Prod Account)
│   │   └── staging/    (Points to Staging Account)
│   ├── app-02/
│   │   └── production/
│   ...
```

### B. Provider Aliasing
Used when you need to talk to two accounts in the *same* terraform file (e.g., VPC Peering).
```hcl
provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}
```

### C. Assume Role
The best practice is to have a "Deployment Role" in each account. Terraform assumes that role to perform actions.

## 4. How to handle "5 vs 10 Applications" Access
This is **NOT** handled inside the `.tf` files. It is handled by **Governance**:

1.  **Git Access Control**:
    - Use `CODEOWNERS` files.
    - Put each app in its own Git repository or a strictly controlled sub-folder.
    - Users only have "Merge" access to the apps they are allowed to touch.

2.  **CI/CD Permission Isolation**:
    - When a user triggers "Deploy App 1", the CI/CD pipeline uses an IAM Role that **only** has permissions to App 1's resources.
    - Users don't have local AWS credentials; they only have "Git Push" rights.

3.  **State File Isolation**:
    - Store state files in different S3 paths: `s3://my-terraform-state/app-01/terraform.tfstate`.
    - Use IAM policies on the S3 bucket to deny users access to state files they shouldn't see.

## 5. Summary Technical Answer for Interviewer
"To handle multiple accounts, I use a folder-based structure with separate backend configurations and AWS Providers that use `assume_role` to target specific accounts. For application-level access (5 vs 10 apps), I implement **Blast Radius Isolation** by separating the applications into distinct state files and governing access via Git permissions and CI/CD-specific IAM roles. This ensures that a developer's access is restricted at the source (Git) and the execution (IAM), rather than hardcoding logic into Terraform itself."

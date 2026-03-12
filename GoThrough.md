# GoThrough - Enterprise Multi-Region EKS Blueprint

> [!IMPORTANT]
> **START HERE**: The very first command you must run is in `infrastructure/bootstrap/`. You cannot proceed with other regions until the Remote State (S3 & DynamoDB) is created.

This document explains the architecture, folder structure, and deployment steps for the  EKS setup. .

---

## 1. Project Anatomy (The Folder Structure)

### `infrastructure/bootstrap/`
*   **Purpose**: The "Seed" of the project.
*   **What it does**: Creates the S3 Bucket and DynamoDB table. Without this, Terraform has nowhere to save its state.
*   **Key File**: `main.tf` calls the `terraform_state` module.

### `infrastructure/modules/` (The Building Blocks)
This is where the actual code lives. It's granular so you can change one part without breaking others.
*   **`network/`**: Creates the VPC (Virtual Private Cloud) with 3 Public and 3 Private subnets (Multi-AZ).
*   **`eks_cluster/`**: The EKS Control Plane. It has **VPC CNI Network Policy** enabled by default for security.
*   **`database/`**: Sets up **Aurora Global Database**. It handles "one-way" data sync from Mumbai to Singapore.
*   **`vpc_peering/`**: The "Secret Bridge." It connects Mumbai and Singapore directly via AWS's private fiber.
*   **`gitops/`**: Installs **ArgoCD**. This ensures your apps are always in sync with your Git repo.
*   **`global_accelerator/`**: The "Global Brain." It provides two static IPs that route users to the closest healthy region.

### `infrastructure/prod_region_a/` & `prod_region_b/`
*   **Purpose**: The "Regional Deployment."
*   **What it does**: These files "wire together" the modules for Mumbai and Singapore. They define the specific CIDRs, instance types, and naming for each region.

### `infrastructure/global/`
*   **Purpose**: The "Global Orchestration."
*   **What it does**: It sits above both regions and manages the Global Accelerator and high-level DNS.

---

## 2. The Deployment Journey (Step-by-Step)

### Step 1: Bootstrapped Foundation
*   **Action**: `cd infrastructure/bootstrap && terraform apply`
*   **Why**: Creates your S3/DynamoDB state storage.
*   **Handshake**: Once complete, both regions can now "talk" to the same state backend.

### Step 2: Mumbai (Primary)
*   **Action**: `cd infrastructure/prod_region_a && terraform apply`
*   **Why**: You establish the "Writer" region.
*   **Interconnection**: This creates the **Database Primary** and sends a **Peering Request** to Singapore.

### Step 3: Singapore (Secondary)
*   **Action**: `cd infrastructure/prod_region_b && terraform apply` (After updating Peering IDs)
*   **Why**: You establish the "Reader" region.
*   **Interconnection**: This **Accepts the Peering** from Mumbai and creates a **Database Replica** that pulls data from Mumbai.

### Step 4: Global Entry
*   **Action**: `cd infrastructure/global && terraform apply`
*   **Why**: You put the "Front Door" (Global Accelerator) on your house.
*   **Interconnection**: It takes the Load Balancers from Step 2 and Step 3 and creates a unified global URL.

---

## 3. Explanation

"Why is this the best approach?":

**"we have built a World-Class infrastructure based on three pillars:"**

1.  **Extreme High Availability (Active-Active)**:
    "We aren't just in one region. We are in Mumbai and Singapore simultaneously. If an entire region goes offline, our **Global Accelerator** will reroute the users to the second region in seconds. We have a 99.99% uptime target."

2.  **Zero-Trust Security**:
    "We use **Kubernetes Network Policies** to isolate traffic so the Frontend can't talk to the DB directly. We also use **VPC Peering** so our cross-region data never touches the public internet."

3.  **Data Consistency**:
    "We use **Aurora Global Database**. This means the data is replicated between regions in under a second. Even in a disaster, your data is safe and synchronized."

4.  **Operational Excellence (GitOps)**:
    "We use **ArgoCD**. This means our deployments are automated. We don't make mistakes by hand; we manage everything via Git. If the code is in Git, it's in the cluster."

---

## Summary of Connectivity
*   **Module A to Module B**: Networking provides the VPC ID; Security adds the Firewall Rules; EKS uses both.
*   **Region A to Region B**: Connected via **VPC Peering** (Traffic) and **Aurora Global Cluster** (Data).
*   **User to Regions**: Connected via **Global Accelerator** (Traffic entry).
*   **Git to Pods**: Connected via **ArgoCD** (Automation).

---

## 4. Why Primary/Secondary for the Database?

A common question is: *"Why not make both regions Primary?"*

**The Technical Answer**: 
Relational databases (SQL) require absolute consistency. If both regions could write simultaneously, you risk "data drift" or "split-brain" where the two regions disagree on the data. 

**The Solution in this Plan**:
We use **Aurora Global Database** which provides:
1.  **Global Performance**: Local "Read" speed in both regions.
2.  **Data Integrity**: A single "Writer" (Primary) to prevent data corruption.
3.  **Elite Disaster Recovery**: If the Primary region fails, the Secondary is promoted to Primary automatically in seconds.

---

## 5. What is AWS Global Accelerator?

Think of it as the **"Smart Front Door"** for the global infrastructure.

1.  **Static IPs**: Provides 2 permanent IP addresses for the whole world. No more DNS propagation issues.
2.  **AWS Backbone**: Traffic travels over AWS private fiber, not the public internet. It's faster and more stable.
3.  **Instant Failover**: It detects a regional failure and reroutes traffic in seconds (not minutes like DNS).

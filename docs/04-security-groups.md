# Stage 04 — Security Groups

## Objective

Define network-level access controls for the compute resources in the Terraform DevOps infrastructure.

## Security Group Design

The security group is currently defined in:

`terraform/security-groups.tf`

It is intended to control inbound traffic to the EC2 compute layer.

## Inbound Rules

| Protocol | Port | Purpose |
|---|---:|---|
| TCP | 22 | SSH administration |
| TCP | 80 | HTTP web traffic |

## Security Principles

The project follows the principle of least privilege.

Security-group rules should allow only the traffic required by the workload.

SSH access should eventually be restricted to a trusted source IP or controlled administrative network rather than being broadly exposed.

HTTP access is required for the planned web workload.

## Architecture

```text
Internet
   |
   v
+----------------------+
|   Security Group     |
|----------------------|
| TCP 22  - SSH       |
| TCP 80  - HTTP      |
+----------------------+
           |
           v
      EC2 Instance

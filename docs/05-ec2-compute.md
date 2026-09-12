# Stage 05 — EC2 Compute

## Objective

Introduce the first compute workload into the AWS infrastructure using an EC2 instance managed entirely through Terraform.

## Architecture

The EC2 instance will be deployed into a public subnet so that the initial project can demonstrate controlled SSH and HTTP access.

```text
Internet
    |
    v
Internet Gateway
    |
    v
Public Subnet
10.0.1.0/24
    |
    v
+------------------+
|   EC2 Instance   |
|------------------|
| SSH :22          |
| HTTP :80         |
+------------------+
    |
    v
EC2 Security Group

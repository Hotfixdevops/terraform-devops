# Stage 06 — IAM and Least Privilege

## Objective

Introduce IAM resources for the EC2 web server using an EC2 instance profile and IAM role.

The goal is to establish a secure identity model for EC2 without granting unnecessary administrative permissions.

## IAM Architecture

```text
EC2 Web Server
      |
      v
IAM Instance Profile
      |
      v
IAM Role
      |
      v
EC2 Trust Policy
      |
      v
ec2.amazonaws.com

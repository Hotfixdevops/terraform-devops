# 07 - EC2 Instance Login Guide

This document explains how to connect to the EC2 instance created by Terraform using SSH.

## Prerequisites

The EC2 instance must already be created by Terraform.

Verify the Terraform outputs:

```bash
cd ~/terraform-devops/terraform
terraform output
ssh -i ~/.ssh/terraform-devops-laptop2.pem ec2-user@<EC2_PUBLIC_IP>

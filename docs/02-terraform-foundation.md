# Stage 02 — Terraform Foundation

## Objective

Establish the Terraform project structure and configuration required to manage AWS infrastructure using Infrastructure as Code.

## Root Terraform Files

The root Terraform configuration is located under:

`terraform/`

Important files include:

- `versions.tf` — Terraform and provider version constraints
- `providers.tf` — AWS provider configuration
- `variables.tf` — Input variables
- `outputs.tf` — Infrastructure outputs
- `main.tf` — Root module configuration
- `security-groups.tf` — Security group configuration

## Module Structure

Reusable infrastructure is organized under:

`terraform/modules/`

The VPC is implemented as a reusable module.

## Validation Workflow

Terraform configuration should be formatted and validated before planning:

```bash
terraform fmt -recursive
terraform init
terraform validate
terraform plan

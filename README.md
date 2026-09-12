# Terraform DevOps Infrastructure

## Project Overview

This repository is a hands-on, enterprise-oriented Infrastructure as
Code (IaC) project built with **Terraform** and **AWS**.

The project is being developed incrementally so that every
infrastructure layer is understandable, reusable, version-controlled,
and independently verifiable.

### Current implementation status

  Layer                                   Status
  --------------------------------------- -------------
  Terraform project foundation            ✅ Complete
  Terraform provider/version management   ✅ Complete
  Reusable VPC module                     ✅ Complete
  VPC networking                          ✅ Complete
  Public subnets                          ✅ Complete
  Private subnets                         ✅ Complete
  Internet Gateway                        ✅ Complete
  Public route table                      ✅ Complete
  NAT Gateway + Elastic IP                ✅ Complete
  Private route table                     ✅ Complete
  EC2 security group                      ✅ Complete
  Git/GitHub version control              ✅ Complete
  EC2 compute                             ⏳ Next
  Application deployment                  ⏳ Planned
  Load Balancer                           ⏳ Planned
  CI/CD                                   ⏳ Planned
  Monitoring/observability                ⏳ Planned

> **Important:** Up to this checkpoint, `terraform apply` has not been
> executed. The configuration has been formatted, validated, and
> planned, but no AWS infrastructure has been created by Terraform.

------------------------------------------------------------------------

# 1. Architecture at the Current Checkpoint

The current Terraform configuration builds the foundation for a secure
AWS network and prepares a security group for the upcoming EC2 layer.

``` text
                           AWS Account
                               |
                               |
                         ap-south-1
                               |
                         +-----------+
                         |    VPC    |
                         | 10.0.0.0/16
                         +-----------+
                               |
              +----------------+----------------+
              |                                 |
        Public Subnets                    Private Subnets
        10.0.1.0/24                       10.0.11.0/24
        10.0.2.0/24                       10.0.12.0/24
              |                                 |
              |                                 |
        Internet Gateway                  NAT Gateway
              |                                 |
              +-----------------+---------------+
                                |
                         Internet connectivity

                    EC2 Security Group
                    -------------------
                    SSH  : TCP/22
                    HTTP : TCP/80
                    Egress: All
```

### Network design

The VPC uses:

``` text
VPC CIDR: 10.0.0.0/16
```

Public subnets:

``` text
10.0.1.0/24
10.0.2.0/24
```

Private subnets:

``` text
10.0.11.0/24
10.0.12.0/24
```

The public subnets use an Internet Gateway for direct internet routing.

The private subnets use a NAT Gateway located in the first public subnet
for outbound internet access without making the private subnets directly
public.

------------------------------------------------------------------------

# 2. Repository Structure

Current repository structure:

``` text
terraform-devops/
│
├── README.md
│
├── docs/
│
├── scripts/
│
└── terraform/
    │
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── variables.tf
    ├── versions.tf
    ├── security-groups.tf
    │
    └── modules/
        │
        └── vpc/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
```

Terraform's working directory is:

``` bash
cd ~/terraform-devops/terraform
```

This is important because Terraform configuration files are stored
inside the `terraform/` directory rather than the repository root.

------------------------------------------------------------------------

# 3. Why We Use This File Structure

The project intentionally separates Terraform responsibilities.

  File                         Responsibility
  ---------------------------- ----------------------------------------------
  `versions.tf`                Terraform and provider version constraints
  `providers.tf`               AWS provider configuration
  `variables.tf`               Root input variables
  `main.tf`                    Root module composition
  `outputs.tf`                 Values exposed after infrastructure creation
  `security-groups.tf`         EC2 network security rules
  `modules/vpc/main.tf`        VPC networking resources
  `modules/vpc/variables.tf`   VPC module inputs
  `modules/vpc/outputs.tf`     VPC module outputs

This separation improves:

-   Maintainability
-   Readability
-   Reusability
-   Troubleshooting
-   Code review
-   Team collaboration
-   Future CI/CD integration
-   Enterprise governance

Terraform does not require this exact file separation. Terraform loads
all `.tf` files in the same directory, but separating responsibilities
makes the project easier for humans to understand and maintain.

------------------------------------------------------------------------

# 4. Terraform Foundation

## 4.1 `versions.tf`

``` hcl
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

### Why this file is needed

`versions.tf` defines the software dependencies required by the
Terraform configuration.

It establishes:

1.  The minimum Terraform version.
2.  The AWS provider source.
3.  The allowed AWS provider version range.

### Why version constraints matter

Without version constraints, a team may accidentally run different
versions of Terraform or the AWS provider.

That can lead to:

-   Unexpected behavior
-   Provider incompatibilities
-   CI/CD differences
-   Configuration drift
-   Difficult troubleshooting

The provider lock file:

``` text
.terraform.lock.hcl
```

also records the selected provider version and checksums.

------------------------------------------------------------------------

# 5. AWS Provider Configuration

## 5.1 `providers.tf`

``` hcl
provider "aws" {
  region = var.aws_region
}
```

### Why this file is needed

The AWS provider tells Terraform how to communicate with AWS.

The region is intentionally supplied through a variable instead of
hard-coded directly into the provider block.

This makes the configuration easier to reuse in another environment or
AWS region.

------------------------------------------------------------------------

# 6. Root Variables

## 6.1 `variables.tf`

``` hcl
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "terraform-devops"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}
```

### Why variables are important

Variables prevent configuration values from being scattered throughout
Terraform code.

For example, instead of repeatedly writing:

``` text
10.0.0.0/16
```

the configuration uses:

``` hcl
var.vpc_cidr
```

This makes the infrastructure easier to parameterize.

### Current inputs

  Variable                 Default              Purpose
  ------------------------ -------------------- ------------------------
  `aws_region`             `ap-south-1`         AWS deployment region
  `vpc_cidr`               `10.0.0.0/16`        VPC address range
  `environment`            `dev`                Environment identifier
  `project`                `terraform-devops`   Resource naming
  `public_subnet_cidrs`    Two `/24` ranges     Public subnet ranges
  `private_subnet_cidrs`   Two `/24` ranges     Private subnet ranges

------------------------------------------------------------------------

# 7. Root Module Composition

## 7.1 `main.tf`

``` hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  project              = var.project
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}
```

### Why this file is important

The root `main.tf` acts as the composition layer.

Instead of defining every VPC resource directly in the root
configuration, it calls a reusable module:

``` text
./modules/vpc
```

This is an important Infrastructure as Code design pattern.

The root module answers:

> "Which infrastructure components does this environment use?"

The VPC module answers:

> "How is the VPC infrastructure implemented?"

------------------------------------------------------------------------

# 8. Reusable VPC Module

The VPC module is located at:

``` text
terraform/modules/vpc/
```

It contains:

``` text
main.tf
variables.tf
outputs.tf
```

------------------------------------------------------------------------

# 9. VPC Module Inputs

## 9.1 `modules/vpc/variables.tf`

``` hcl
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}
```

### Why module variables exist

A reusable module should not depend directly on root-level variables.

The root module passes values into the VPC module.

Conceptually:

``` text
Root variables
      |
      v
Root main.tf
      |
      v
VPC module inputs
      |
      v
VPC resources
```

This makes the VPC module reusable for different environments.

------------------------------------------------------------------------

# 10. VPC Networking Implementation

## 10.1 `modules/vpc/main.tf`

``` hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project}-vpc"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project}-public-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Tier        = "public"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project}-private-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Tier        = "private"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${var.project}-igw"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-public-rt"
    Environment = var.environment
    Project     = var.project
    Tier        = "public"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${var.project}-nat-eip"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  depends_on = [
    aws_internet_gateway.this
  ]

  tags = {
    Name        = "${var.project}-nat"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${var.project}-private-rt"
    Environment = var.environment
    Project     = var.project
    Tier        = "private"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
```

------------------------------------------------------------------------

# 11. Explanation of VPC Resources

## `data "aws_availability_zones"`

``` hcl
data "aws_availability_zones" "available" {
  state = "available"
}
```

This reads the currently available Availability Zones from AWS.

The module then uses those AZs to distribute public and private subnets.

This avoids hard-coding Availability Zone names.

------------------------------------------------------------------------

## `aws_vpc`

Creates the main VPC:

``` text
10.0.0.0/16
```

DNS support and DNS hostnames are enabled because they are commonly
required by AWS workloads and service integrations.

------------------------------------------------------------------------

## Public subnets

Two public subnets are created:

``` text
10.0.1.0/24
10.0.2.0/24
```

They use:

``` hcl
map_public_ip_on_launch = true
```

This allows resources launched into those subnets to receive public IPv4
addresses when the relevant resource configuration permits it.

Public subnets are intended for components that need direct internet
reachability, such as a future load balancer or NAT Gateway.

------------------------------------------------------------------------

## Private subnets

Two private subnets are created:

``` text
10.0.11.0/24
10.0.12.0/24
```

They do not automatically receive public IP addresses.

They are intended for workloads that should not be directly reachable
from the public internet.

------------------------------------------------------------------------

## Internet Gateway

The Internet Gateway provides internet connectivity for resources using
routes through the public route table.

Architecture:

``` text
Public Subnet
     |
Public Route Table
     |
Internet Gateway
     |
Internet
```

------------------------------------------------------------------------

## Public Route Table

The public route table contains:

``` text
0.0.0.0/0 -> Internet Gateway
```

This means traffic destined for addresses outside the VPC can be routed
through the Internet Gateway.

------------------------------------------------------------------------

## NAT Gateway

The NAT Gateway is placed in:

``` text
public_subnet[0]
```

It allows resources in private subnets to initiate outbound internet
connections while remaining without direct inbound internet routing.

Architecture:

``` text
Private Subnet
      |
Private Route Table
      |
NAT Gateway
      |
Public Subnet
      |
Internet Gateway
      |
Internet
```

> **Cost consideration:** NAT Gateways can incur AWS charges. Before
> running `terraform apply`, review current AWS pricing and your
> account's free-tier/credit eligibility.

------------------------------------------------------------------------

## Elastic IP

The NAT Gateway uses an Elastic IP.

``` hcl
resource "aws_eip" "nat"
```

The EIP provides a stable public IPv4 address for the NAT Gateway.

------------------------------------------------------------------------

## Private Route Table

Private subnets use:

``` text
0.0.0.0/0 -> NAT Gateway
```

This gives private workloads outbound internet access through the NAT
Gateway.

------------------------------------------------------------------------

# 12. VPC Module Outputs

## 12.1 `modules/vpc/outputs.tf`

``` hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "nat_eip_public_ip" {
  description = "Public IP address of the NAT Gateway Elastic IP"
  value       = aws_eip.nat.public_ip
}
```

### Why outputs are needed

Outputs expose useful resource attributes from a module.

For example:

``` hcl
module.vpc.public_subnet_ids
```

can be consumed by future EC2 resources.

This creates a clean dependency between infrastructure layers.

Example:

``` text
VPC module
    |
    +---- VPC ID
    |
    +---- Public subnet IDs
    |
    +---- Private subnet IDs
    |
    +---- NAT Gateway ID
    |
    v
Future EC2 / ALB / application layers
```

------------------------------------------------------------------------

# 13. Root Outputs

## 13.1 `outputs.tf`

``` hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "nat_eip_public_ip" {
  description = "Public IP address of the NAT Gateway Elastic IP"
  value       = module.vpc.nat_eip_public_ip
}
```

### Why root outputs exist

The VPC module has its own outputs.

The root module exposes those outputs to the Terraform user.

This gives a clean interface:

``` text
AWS resources
     |
VPC module outputs
     |
Root outputs
     |
terraform output
```

------------------------------------------------------------------------

# 14. EC2 Security Group

## 14.1 `security-groups.tf`

``` hcl
resource "aws_security_group" "ec2" {
  name        = "${var.project}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-ec2-sg"
    Environment = var.environment
    Project     = var.project
  }
}
```

### Why a security group is needed

A security group acts as a virtual firewall for EC2 instances and other
supported AWS resources.

Current rules:

  Direction   Protocol     Port Source/Destination   Purpose
  ----------- ---------- ------ -------------------- -----------------------
  Inbound     TCP            22 `0.0.0.0/0`          SSH
  Inbound     TCP            80 `0.0.0.0/0`          HTTP
  Outbound    All           All `0.0.0.0/0`          Outbound connectivity

### Important security note

The current SSH rule:

``` text
0.0.0.0/0
```

allows SSH from any IPv4 address.

This is acceptable as a temporary learning configuration, but it is
**not an enterprise production security posture**.

A production implementation should normally restrict SSH access to a
controlled source, use Systems Manager where appropriate, use a
bastion/access layer when required, or otherwise follow the
organization's approved administrative-access model.

We will harden this as the project evolves.

------------------------------------------------------------------------

# 15. Resource Naming and Tags

Resources use a consistent naming pattern:

``` text
${var.project}-<resource>
```

Examples:

``` text
terraform-devops-vpc
terraform-devops-igw
terraform-devops-public-1
terraform-devops-private-1
terraform-devops-nat
terraform-devops-nat-eip
terraform-devops-ec2-sg
```

Resources also receive:

``` text
Name
Environment
Project
```

and subnets additionally receive:

``` text
Tier
```

### Why tagging matters

Consistent tags help with:

-   Resource identification
-   Cost allocation
-   Operations
-   Automation
-   Governance
-   Auditing
-   Troubleshooting

A mature enterprise implementation can later extend this to tags such
as:

``` text
Owner
Application
CostCenter
ManagedBy
DataClassification
Environment
Project
```

according to organizational policy.

------------------------------------------------------------------------

# 16. Terraform Workflow Used in This Project

The project follows this general workflow:

``` text
Write Terraform
      |
      v
terraform fmt
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
Code review / verification
      |
      v
terraform apply
      |
      v
Infrastructure
```

At the current checkpoint, we have intentionally stopped before:

``` text
terraform apply
```

------------------------------------------------------------------------

# 17. Terraform Initialization

From the Terraform directory:

``` bash
cd ~/terraform-devops/terraform
```

Initialize Terraform:

``` bash
terraform init
```

This downloads required providers and initializes the working directory.

The project uses the AWS provider from:

``` text
registry.terraform.io/hashicorp/aws
```

------------------------------------------------------------------------

# 18. Formatting

Run:

``` bash
terraform fmt -recursive
```

### Purpose

Terraform formatting ensures consistent HCL formatting across the
project.

This should normally be part of local development and CI checks.

------------------------------------------------------------------------

# 19. Validation

Run:

``` bash
terraform validate
```

Expected result:

``` text
Success! The configuration is valid.
```

Validation checks the Terraform configuration for syntax and internal
configuration errors.

It does not create infrastructure.

------------------------------------------------------------------------

# 20. Terraform Plan

Run:

``` bash
terraform plan
```

At the current checkpoint, the plan reported:

``` text
Plan: 15 to add, 0 to change, 0 to destroy.
```

This means Terraform calculated 15 resources that would be created if
the plan were applied.

The plan also showed these root outputs as values that would become
known after creation:

``` text
internet_gateway_id
nat_eip_public_ip
nat_gateway_id
private_subnet_ids
public_subnet_ids
vpc_id
```

No infrastructure was created by `terraform plan`.

------------------------------------------------------------------------

# 21. Terraform Apply Policy

For this learning project, `terraform apply` should only be executed
after explicitly reviewing the plan and confirming that AWS resource
creation is intended.

Command:

``` bash
terraform apply
```

### Current status

``` text
NOT RUN
```

Therefore, the current AWS infrastructure state has not been created by
this Terraform project.

> **Cost warning:** The NAT Gateway and associated public IPv4/EIP
> resources can generate AWS charges. Review AWS pricing and
> account-specific credits/free-tier eligibility before applying.

------------------------------------------------------------------------

# 22. Git and GitHub

The project is maintained using Git.

Current branch:

``` text
main
```

GitHub repository:

``` text
git@github.com:Hotfixdevops/terraform-devops.git
```

The repository is configured with:

``` text
origin -> GitHub
```

Current branch tracking:

``` text
main -> origin/main
```

The latest committed checkpoint is:

``` text
6b9569c Add EC2 security group
```

The working tree was clean at the checkpoint:

``` text
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

### Why Git is important for Terraform

Infrastructure code must be version-controlled because changes to
infrastructure are operational changes.

Git provides:

-   Change history
-   Code review
-   Rollback capability
-   Collaboration
-   Auditability
-   CI/CD integration
-   Traceability

------------------------------------------------------------------------

# 23. `.gitignore` and Terraform Safety

The repository ignores Terraform-generated and sensitive files such as:

``` text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
*.tfvars.json
*.pem
*.key
```

### Why this matters

Terraform state can contain sensitive infrastructure information.

Private keys and secret variable files should never be committed to a
public Git repository.

For a production implementation, remote state should generally be
managed using an approved backend with appropriate access controls,
encryption, locking/state-concurrency controls, and organizational
governance.

------------------------------------------------------------------------

# 24. Enterprise Design Principles Being Applied

This project is intentionally following several Infrastructure as Code
principles.

### 24.1 Infrastructure as Code

AWS infrastructure is described declaratively instead of being manually
created through the AWS console.

### 24.2 Modularity

The VPC is implemented as a reusable module.

### 24.3 Parameterization

Important configuration values are exposed through variables.

### 24.4 Separation of concerns

Networking, provider configuration, variables, outputs, and security
rules are separated logically.

### 24.5 Version control

All Terraform source code is maintained in Git.

### 24.6 Validation before deployment

The project uses:

``` text
fmt -> validate -> plan -> review -> apply
```

### 24.7 Least privilege and security hardening

The current security group is a learning baseline. Future stages should
progressively tighten administrative access and application exposure.

### 24.8 Repeatability

The infrastructure can be recreated consistently from the Terraform
configuration rather than relying on undocumented manual AWS console
actions.

------------------------------------------------------------------------

# 25. Current Resource Dependency Flow

The Terraform dependency chain currently looks approximately like:

``` text
AWS Provider
     |
     v
Availability Zones
     |
     v
VPC
     |
     +----------------------+
     |                      |
     v                      v
Public Subnets        Private Subnets
     |                      |
     v                      v
Internet Gateway      Private Route Table
     |                      |
     v                      v
Public Route Table     NAT Gateway
     |                      |
     +----------+-----------+
                |
                v
        EC2 Security Group
```

The actual Terraform graph is determined by resource references and
dependencies.

For example:

``` hcl
vpc_id = module.vpc.vpc_id
```

creates a dependency on the VPC module output.

------------------------------------------------------------------------

# 26. What Has Been Completed

## Phase 1 --- Terraform Foundation

Completed:

-   Project directory structure
-   Terraform configuration
-   AWS provider
-   Terraform version constraint
-   Provider version constraint
-   Root variables
-   Root outputs
-   `.gitignore`
-   Git repository

## Phase 2 --- VPC Networking

Completed:

-   VPC
-   DNS support
-   DNS hostnames
-   Availability Zone lookup
-   Public subnets
-   Private subnets
-   Internet Gateway
-   Public route table
-   Public route associations
-   Elastic IP
-   NAT Gateway
-   Private route table
-   Private route associations
-   VPC module outputs

## Phase 3 --- Security

Completed:

-   EC2 security group
-   SSH rule
-   HTTP rule
-   Outbound rule
-   Resource tags

## Phase 4 --- Source Control

Completed:

-   Local Git commits
-   GitHub repository
-   `main` branch
-   `origin` remote
-   Initial project push
-   Clean working tree

------------------------------------------------------------------------

# 27. Next Phase --- EC2 Compute

The next implementation phase is EC2.

Planned architecture:

``` text
                    VPC
                     |
              Public Subnet
                     |
              EC2 Instance
                     |
             EC2 Security Group
                /          \
             SSH           HTTP
```

The EC2 layer will consume outputs from the VPC module instead of
recreating networking resources.

For example, the future EC2 configuration will use:

``` hcl
module.vpc.public_subnet_ids[0]
```

for the target subnet and:

``` hcl
aws_security_group.ec2.id
```

for network access control.

The EC2 layer will then become the foundation for the future application
deployment, load balancer, CI/CD, and monitoring stages.

------------------------------------------------------------------------

# 28. Planned Future Architecture

The eventual project is intended to evolve toward a more complete DevOps
platform:

``` text
                         GitHub
                            |
                            v
                         CI/CD
                            |
                            v
                    +---------------+
                    | AWS           |
                    | VPC           |
                    +---------------+
                            |
             +--------------+--------------+
             |                             |
       Public Subnets                Private Subnets
             |                             |
       Load Balancer                 Application EC2
             |                             |
             +-------------+---------------+
                           |
                    Application Layer
                           |
                 +---------+---------+
                 |                   |
            Monitoring           Logging
```

Future phases will be implemented incrementally rather than all at once.

------------------------------------------------------------------------

# 29. Operational Checklist

Before any infrastructure deployment:

``` bash
cd ~/terraform-devops/terraform

terraform fmt -recursive
terraform validate
terraform plan
```

Review:

-   Resource count
-   Resource names
-   Network CIDRs
-   Security group rules
-   AWS region
-   NAT Gateway cost implications
-   Any unexpected changes
-   Any destroy operations

Only after explicit approval should:

``` bash
terraform apply
```

be considered.

------------------------------------------------------------------------

# 30. Current Checkpoint

``` text
Project:       terraform-devops
Cloud:         AWS
Region:        ap-south-1
Terraform:     >= 1.6.0
AWS Provider:  ~> 6.0

Foundation:    COMPLETE
VPC:           COMPLETE
Networking:    COMPLETE
Security:      COMPLETE
GitHub:        COMPLETE
EC2:           NEXT

Terraform apply:
NOT RUN

Latest Git commit:
6b9569c Add EC2 security group

Working tree:
CLEAN
```

------------------------------------------------------------------------

# 31. Key Learning Outcomes So Far

By this checkpoint, the project demonstrates practical understanding of:

-   Terraform project organization
-   Terraform providers
-   Version constraints
-   Input variables
-   Outputs
-   Modules
-   AWS VPCs
-   CIDR planning
-   Availability Zones
-   Public/private subnet design
-   Internet Gateways
-   Route tables
-   Route table associations
-   NAT Gateways
-   Elastic IPs
-   Security Groups
-   Resource tagging
-   Terraform dependency management
-   `terraform init`
-   `terraform fmt`
-   `terraform validate`
-   `terraform plan`
-   Git version control
-   GitHub repository management
-   Infrastructure documentation

------------------------------------------------------------------------

# 32. Important Project Rule

This project is intentionally built in controlled stages.

**Do not skip directly to production-style complexity.**

Each layer should be:

``` text
Understand
   ↓
Implement
   ↓
Format
   ↓
Validate
   ↓
Plan
   ↓
Review
   ↓
Commit
   ↓
Deploy when explicitly approved
```

This approach keeps the infrastructure understandable while gradually
introducing enterprise DevOps practices.

------------------------------------------------------------------------

## End of Current Checkpoint

**Next step: EC2 Compute.**

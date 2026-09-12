# Stage 03 — VPC Networking

## Objective

Create the AWS network foundation required by the application infrastructure.

## Network Design

The VPC uses:

- VPC CIDR: `10.0.0.0/16`
- Two public subnets
- Two private subnets
- Internet Gateway
- NAT Gateway
- Public and private route tables

## Subnet Design

### Public Subnets

- `10.0.1.0/24`
- `10.0.2.0/24`

Public subnets are intended for resources that require controlled inbound internet connectivity.

### Private Subnets

- `10.0.11.0/24`
- `10.0.12.0/24`

Private subnets are intended for resources that should not receive direct inbound internet traffic.

## Terraform Module

The VPC implementation is located at:

`terraform/modules/vpc/`

The module separates networking logic from the root configuration and improves reusability.

## Architecture

```text
                         Internet
                            |
                    Internet Gateway
                            |
              +-------------+-------------+
              |                           |
        Public Subnet 1             Public Subnet 2
         10.0.1.0/24                 10.0.2.0/24
              |
          NAT Gateway
              |
        Private Route Tables
              |
       +------+------+
       |             |
 Private Subnet 1  Private Subnet 2
 10.0.11.0/24      10.0.12.0/24

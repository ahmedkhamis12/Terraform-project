# AWS Infrastructure Setup with Terraform

This project provisions a basic AWS infrastructure using Terraform, including a VPC, subnet, EC2 instance, security group, and other resources. The EC2 instance runs an NGINX server inside a Docker container.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Infrastructure Overview](#infrastructure-overview)
- [Getting Started](#getting-started)
- [Variables](#variables)
- [Outputs](#outputs)
- [Usage](#usage)
- [Clean Up](#clean-up)
- [License](#license)

## Prerequisites

To deploy this infrastructure, you will need the following:
- [Terraform](https://www.terraform.io/downloads.html) installed.
- AWS account credentials configured with the AWS CLI.
- An SSH key pair for accessing the EC2 instance.

## Infrastructure Overview

This project sets up the following AWS resources:
- **VPC**: A Virtual Private Cloud to host your infrastructure.
- **Subnet**: A public subnet within the VPC.
- **Internet Gateway**: Allows internet access for the instances.
- **Route Table**: Routes traffic from the subnet through the Internet Gateway.
- **Security Group**: Controls traffic to the EC2 instance (SSH and HTTP access).
- **EC2 Instance**: Runs an NGINX web server inside a Docker container.
- **Key Pair**: Used to SSH into the EC2 instance.

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/aws-terraform-project.git
   cd aws-terraform-project

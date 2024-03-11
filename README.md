# Multi-Region AWS Infrastructure with Transit Gateway Peering Workshop

 ⚠️ Warning ⚠️ It should not be used in a production environment without thorough review and refactoring to ensure compliance with your organization's security and compliance requirements.

This README provides a detailed step by step guide for setting up an AWS infrastructure across two regions using Terraform. It ensures the creation  of tree key components in each region: Transit Gateways (TGW), VPCs and EC2 Instances. The setup enables inter-region connectivity and resource deployment, showcasing an advanced cloud architecture that leverages AWS's global network.

The Terraform configurations included in this guide covers the following:

* AWS Provider Setup: Configure providers for two AWS regions.
* VPC and Subnet Creation: Define VPCs and subnets for network segmentation.
* EC2 Instances Deployment: Launch EC2 instances with security groups and IAM roles for resource access and management.
* Transit Gateway Setup: Establish TGWs in each region for intra- and inter-region connectivity.
* Transit Gateway Peering: Create and accept TGW peering attachments for cross-region communication.
* Route Table Updates: Configure route tables for directing traffic through the TGW peering connection and to the internet.

## Prerequisites

Terraform installed on your local machine
Understanding of AWS services (VPC, EC2, IAM, TGW)

## Configuration Variables

`terraform.tfvars`

region1 = "us-east-1"

The AWS region for the first part of the infrastructure.

cidr_block_vpc_1 = "10.2.0.0/16"
CIDR block for the VPC in region1.

region2 = "ap-southeast-2"
The AWS region for the second part of the infrastructure.

cidr_block_vpc_2 = "10.1.0.0/16"
CIDR block for the VPC in region2.


tgw_enabled = true
Enables  the Transit Gateways peering between the two regions.

policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
IAM policy attached to the Ec2 instances to grant access to AWS Systems Manager.

## Deployment Steps

### Step 1: Generate AWS Credentials with Admin Permissions

To deploy resources on AWS, you need to have credentials with admin permissions. Follow these steps to create a new IAM user and generate credentials:

1. Sign in to the AWS Management Console.
2. Navigate to the IAM dashboard.
3. Click on "Users" and then "Add user".
4. Enter a user name and select "Programmatic access" for the AWS access type.
5. Click "Next: Permissions" and attach the "AdministratorAccess" policy.
6. Click through the rest of the steps until you reach the "Review" page, then click "Create user".
7. On the final page, you'll see the Access Key ID and Secret Access Key. Save these credentials, as you will need them in the next step.

### Step 2: Add Credentials to the `~/.aws/credentials` File

Add the generated AWS credentials to your `~/.aws/credentials` file. Here is how to add your credentials manually:

1. Open or create the `~/.aws/credentials` file in your favorite text editor.
2. Add the following lines, replacing `<YOUR_ACCESS_KEY_ID>` and `<YOUR_SECRET_ACCESS_KEY>` with your credentials:

### Step 3: Run Make Deploy

With your AWS credentials configured, you're now ready to deploy the project resources. Navigate to the project directory where the Makefile is located and run the following command:

`make deploy`

## Cleaning Up Resources to Avoid Unnecessary Costs

AWS resources like Transit Gateway and EC2 instances incur costs as long as they are running. To avoid unnecessary charges, it's important to clean up these resources when they are no longer needed.

1. **Navigate to your project directory** where the main Makefile is located.

2. **Run the `make destroy` command:**

This command triggers the cleanup process defined under the `destroy` target in your Makefile. It will remove all the deployed resources.

provider "aws" {
  region = var.region
}

# Generate a random string for the cluster name suffix
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Define the local variable for the cluster name
locals {
  cluster_name         = "${var.cluster_name}-${random_string.suffix.result}"
  launch_template_name = local.cluster_name
}

# Filter out local zones, which are not currently supported with managed node groups
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# VPC module configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "finance-cluster-vpc"

  cidr = "10.0.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = 1
  }
}

# EKS module configuration
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name                   = local.cluster_name
  cluster_version                = "1.27"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      name             = "finance-node-group-1"
      instance_type    = var.instance_type
      key_name         = var.key_name
      desired_capacity = var.desired_capacity
      min_size         = var.min_capacity
      max_size         = var.max_capacity
    }

    two = {
      name             = "finance-node-group-2"
      instance_type    = var.instance_type
      key_name         = var.key_name
      desired_capacity = var.desired_capacity
      min_size         = var.min_capacity
      max_size         = var.max_capacity
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# IAM policy for EBS CSI driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# IAM role for EBS CSI driver
module "irsa_ebs_csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${local.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

# EKS Addon for EBS CSI driver
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa_ebs_csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

# CloudWatch Log Group - Check if it exists
data "aws_cloudwatch_log_group" "existing" {
  name = "/aws/eks/${local.cluster_name}/cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  count = data.aws_cloudwatch_log_group.existing.id == "" ? 1 : 0
  name              = "/aws/eks/${local.cluster_name}/cluster"
  retention_in_days = 30

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
  }
}

output "vpc_id" {
  description = "The VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS Cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  description = "EKS Cluster security group id"
  value       = module.eks.cluster_security_group_id
}

output "node_groups" {
  description = "List of EKS managed node group names"
  value       = keys(module.eks.eks_managed_node_groups)
}

output "ebs_csi_driver_role_arn" {
  description = "IAM Role ARN for EBS CSI Driver"
  value       = module.irsa_ebs_csi.iam_role_arn
}
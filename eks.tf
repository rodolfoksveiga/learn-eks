module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${var.owner}-eks-cluster"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    one = {
      name = "${var.owner}-eks-node-group-1"

      min_size     = 1
      max_size     = 3
      desired_size = 2

      capacity_type  = "SPOT"
      instance_types = ["t3.medium"]
    }
  }

  enable_cluster_creator_admin_permissions = true
  tags = {
    Name        = "Cluster"
    Module      = "Eks"
    Environment = var.env
  }
}

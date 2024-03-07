resource "aws_iam_role" "eks-nodes-role" {
  name = "CustomEksNodesRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "EksNodesRole"
    Resource = "Eks"
  }
}

resource "aws_iam_role_policy_attachment" "eks-nodes-role-policy-attachment-1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-role-policy-attachment-2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-nodes-role.name
}

resource "aws_iam_role_policy_attachment" "eks-nodes-role-policy-attachment-3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-nodes-role.name
}

resource "aws_eks_node_group" "eks-nodes-private" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "EksNodesPrivate"
  node_role_arn   = aws_iam_role.eks-nodes-role.arn

  subnet_ids = [
    aws_subnet.subnet-private-a.id,
    aws_subnet.subnet-private-b.id
  ]

  capacity_type  = "SPOT"
  instance_types = ["t3.small"]

  scaling_config {
    desired_size = 1
    max_size     = 5
    min_size     = 0
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-nodes-role-policy-attachment-1,
    aws_iam_role_policy_attachment.eks-nodes-role-policy-attachment-2,
    aws_iam_role_policy_attachment.eks-nodes-role-policy-attachment-3,
  ]

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "EksNodesPrivate"
    Resource = "Eks"
  }
}

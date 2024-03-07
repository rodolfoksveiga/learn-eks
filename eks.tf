resource "aws_iam_role" "eks-cluster-role" {
  name = "CustomEksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "EksClusterRole"
    Resource = "Eks"
  }
}

resource "aws_iam_role_policy_attachment" "eks-cluster-role-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster-role.name
}

resource "aws_eks_cluster" "eks-cluster" {
  name     = "EksCluster"
  role_arn = aws_iam_role.eks-cluster-role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.subnet-private-a.id,
      aws_subnet.subnet-public-a.id,
      aws_subnet.subnet-private-b.id,
      aws_subnet.subnet-public-b.id

    ]
  }

  depends_on = [aws_iam_role_policy_attachment.eks-cluster-role-policy-attachment]

  tags = {
    Contact = "${var.contact}"
    Project = "${var.project}"
    Name    = "EksCluster"
    Resouce = "Eks"
  }
}

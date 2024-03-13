data "aws_caller_identity" "current" {}

resource "aws_iam_role" "shopware-role" {
  name = "ShopwareRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:shopware-service-account"
        }
      }
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
    }]
  })

  tags = {
    Name     = "ShopwareRole"
    Resource = "Iam"
  }
}

resource "aws_iam_policy" "s3-all-policy" {
  name = "S3AllPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:*"
      ]
      Resource = module.s3_bucket.s3_bucket_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "shopware-role-s3-policy-attachment" {
  role       = aws_iam_role.shopware-role.name
  policy_arn = aws_iam_policy.s3-all-policy.arn
}

resource "kubernetes_service_account" "shopware-k8s-service-account" {
  metadata {
    name      = "shopware-service-account"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.shopware-role.arn
    }
  }
}

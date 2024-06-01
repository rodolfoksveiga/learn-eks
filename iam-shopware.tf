locals {
  shopware_service_account_name = "shopware-service-account"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "shopware" {
  name = "ShopwareRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:${local.shopware_service_account_name}"
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

resource "aws_iam_policy" "shopware" {
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

resource "aws_iam_role_policy_attachment" "shopware" {
  role       = aws_iam_role.shopware.name
  policy_arn = aws_iam_policy.shopware.arn
}

resource "kubernetes_service_account" "shopware" {
  metadata {
    name      = local.shopware_service_account_name
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.shopware.arn
    }
  }
}

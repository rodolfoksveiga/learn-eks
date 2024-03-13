resource "aws_iam_role" "argocd-role" {
  name = "ArgoCdRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:argocd:*"
        }
      }
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
    }]
  })

  tags = {
    Name     = "BackendRole"
    Resource = "Iam"
  }
}

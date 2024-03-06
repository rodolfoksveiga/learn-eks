data "aws_iam_policy_document" "backend-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oidc-provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:backend-service-account"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oidc-provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "backend-role" {
  assume_role_policy = data.aws_iam_policy_document.backend-policy.json
  name               = "BackendRole"
}

resource "aws_iam_policy" "s3-all-policy" {
  name = "S3AllPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListAllMyBuckets",
        "s3:GetBucketLocation"
      ]
      Resource = "arn:aws:s3:::*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend-role-policy-attachment" {
  role       = aws_iam_role.backend-role.name
  policy_arn = aws_iam_policy.s3-all-policy.arn
}

output "backend_role_arn" {
  value = aws_iam_role.backend-role.arn
}

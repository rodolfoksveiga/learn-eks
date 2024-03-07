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

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "BackendRole"
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
      Resource = aws_s3_bucket.s3-bucket.arn
    }]
  })
}

resource "aws_iam_policy" "rds-all-policy" {
  name = "RdsAllPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "rds:*"
      ]
      Resource = aws_db_instance.rds-instance.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "backend-role-s3-policy-attachment" {
  role       = aws_iam_role.backend-role.name
  policy_arn = aws_iam_policy.s3-all-policy.arn
}

resource "aws_iam_role_policy_attachment" "backend-role-rds-policy-attachment" {
  role       = aws_iam_role.backend-role.name
  policy_arn = aws_iam_policy.rds-all-policy.arn
}

output "backend_role_arn" {
  description = "Backend Role ARN"
  value       = aws_iam_role.backend-role.arn
}

locals {
  external_secrets_service_account_name = "external-secrets-service-account"
}

data "aws_secretsmanager_secret" "rds-secrets" {
  arn = module.rds.db_instance_master_user_secret_arn

  depends_on = [
    module.rds
  ]
}

resource "helm_release" "external-secrets" {
  name = "external-secrets"

  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  version    = "0.9.13"

  namespace        = "default"
  create_namespace = true
}

# resource "aws_iam_group" "secrets-reader" {
#   name = "secrets-reader-group"
# }
#
# resource "aws_iam_group_policy_attachment" "secrets-reader" {
#   group      = aws_iam_group.secrets-reader.name
#   policy_arn = aws_iam_policy.secrets-reader-policy.arn
# }
#
# resource "aws_iam_user" "secrets-reader" {
#   name = "secrets-reader"
# }
#
# resource "aws_iam_user_group_membership" "secrets-reader" {
#   user = aws_iam_user.secrets-reader.name
#
#   groups = [
#     aws_iam_group.secrets-reader.name,
#   ]
# }
#
# resource "aws_iam_access_key" "secrets-reader" {
#   user = aws_iam_user.secrets-reader.name
# }
#
# resource "kubernetes_secret" "secrets-reader-k8s-secret" {
#   metadata {
#     name      = "aws-secrets-reader-secrets"
#     namespace = "external-secrets"
#   }
#   data = {
#     access-key-id     = aws_iam_access_key.secrets-reader.id
#     access-key-secret = aws_iam_access_key.secrets-reader.secret
#   }
# }

resource "aws_iam_role" "external-secrets" {
  name = "ExternalSecretsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:external-secrets-service-account"
        }
      }
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
    }]
  })

  tags = {
    Name     = "ExternalSecretsRole"
    Resource = "Iam"
  }
}

resource "aws_iam_policy" "secrets-read" {
  name = "SecretsReadPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:ListSecrets",
        "secretsmanager:GetSecretValue"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "secrets-read" {
  role       = aws_iam_role.external-secrets.name
  policy_arn = aws_iam_policy.secrets-read.arn
}

resource "kubernetes_service_account" "external-secrets" {
  metadata {
    name      = local.external_secrets_service_account_name
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.external-secrets.arn
    }
  }
}

resource "kubernetes_manifest" "secret-store" {
  count = var.stack == "all" || var.stack == "k8s" ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "SecretStore"
    metadata = {
      name      = "aws-secret-store"
      namespace = "default"
    }
    spec = {
      provider = {
        aws = {
          service = "SecretsManager"
          region  = var.region
          auth = {
            jwt = {
              serviceAccountRef = {
                name = local.external_secrets_service_account_name
              }
            }
            # secretRef = {
            #   accessKeyIDSecretRef = {
            #     name = "aws-secrets-reader-secrets"
            #     key  = "access-key-id"
            #   }
            #   secretAccessKeySecretRef = {
            #     name = "aws-secrets-reader-secrets"
            #     key  = "access-key-secret"
            #   }
            # }
          }
        }
      }
    }
  }

  # TODO: it still doesn't wait for the helm release installation
  ## HACK: use variable to create services only after helm release is installed
  depends_on = [
    helm_release.external-secrets
  ]
}

resource "kubernetes_manifest" "rds-secrets" {
  count = var.stack == "all" || var.stack == "k8s" ? 1 : 0

  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ExternalSecret"
    metadata = {
      name      = "rds-external-secrets"
      namespace = "default"
    }
    spec = {
      refreshInterval = "1h"
      secretStoreRef = {
        name = "aws-secret-store"
        kind = "SecretStore"
      }
      target = {
        name = "rds-secrets"
      }
      data = [
        {
          secretKey = "username"
          remoteRef = {
            key      = data.aws_secretsmanager_secret.rds-secrets.name
            property = "username"
          }
        },
        {
          secretKey = "password"
          remoteRef = {
            key      = data.aws_secretsmanager_secret.rds-secrets.name
            property = "password"
          }
        }
      ]
    }
  }

  depends_on = [
    helm_release.external-secrets,
    kubernetes_manifest.secret-store
  ]
}

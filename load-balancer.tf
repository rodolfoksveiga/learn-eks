locals {
  controller_name      = "load-balancer-controller"
  service_account_name = "${local.controller_name}-service-account"
  helm_chart_name      = "aws-load-balancer-controller"
}

resource "helm_release" "load-balancer" {
  name = local.controller_name

  repository = "https://aws.github.io/eks-charts"
  chart      = local.helm_chart_name

  namespace = "kube-system"

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = module.vpc.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/${local.helm_chart_name}"
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = local.service_account_name
  }

  depends_on = [
    kubernetes_service_account.load-balancer
  ]
}

module "load_balancer_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name = "${var.owner}-load-balancer"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:${local.service_account_name}"]
    }
  }
}

resource "kubernetes_service_account" "load-balancer" {
  metadata {
    name      = local.service_account_name
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = local.service_account_name
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.load_balancer_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "helm_release" "sealed-secrets" {
  name = "sealed-secrets"

  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"

  namespace        = "sealed-secrets"
  create_namespace = true
}

resource "kubernetes_secret" "sealed-secrets" {
  count = var.stack == "all" || var.stack == "k8s" ? 1 : 0

  metadata {
    name      = "sealed-secrets-key"
    namespace = "sealed-secrets"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = "file(\"keys/tls.crt\")"
    "tls.key" = "file(\"keys/tls.key\")"
  }

  depends_on = [helm_release.sealed-secrets]
}

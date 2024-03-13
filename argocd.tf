# resource "helm_release" "argocd-helm-release" {
#   name = "argocd-helm-release"
#
#   chart      = "argo-cd"
#   repository = "https://argoproj.github.io/argo-helm"
#   version    = "5.42.2"
#
#   namespace        = "argocd"
#   create_namespace = true
#
#   values = [
#     templatefile("./k8s/argocd/values.configs.cmp.yaml", {}),
#     templatefile("./k8s/argocd/values.configs.secret.yaml", {}),
#     templatefile("./k8s/argocd/values.server.tls.yaml", {}),
#     templatefile("./k8s/argocd/values.repo-server.yaml", {}),
#     templatefile("./k8s/argocd/values.repo-server.tls.yaml", {}),
#     templatefile("./k8s/argocd/values.dex.yaml", {}),
#   ]
# }

# resource "null_resource" "password" {
#   provisioner "local-exec" {
#     working_dir = "./argocd"
#     command     = "kubectl -n argocd-staging get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt"
#   }
# }
#
# resource "null_resource" "del-argo-pass" {
#   depends_on = [null_resource.password]
#   provisioner "local-exec" {
#     command = "kubectl -n argocd-staging delete secret argocd-initial-admin-secret"
#   }
# }

# resource "kubernetes_namespace" "argocd" {
#   metadata {
#     name = "argocd"
#   }
# }
#
# resource "kubernetes_config_map" "k8s-argocd-vault-plugin-configmap" {
#   metadata {
#     name      = "argocd-vault-plugin-configmap"
#     namespace = "argocd"
#   }
#
#   data = {
#     AVP_TYPE = "sops"
#   }
# }
#
# resource "kubernetes_secret" "k8s-argocd-vault-plugin-secrets" {
#   metadata {
#     name      = "argocd-vault-plugin-secrets"
#     namespace = "argocd"
#     annotations = {
#       "avp.kubernetes.io/path" = "secrets.sops.yaml"
#     }
#   }
#
#   type = "Opaque"
#
#   data = {
#     SOPS_AGE_KEY = "AGE-SECRET-KEY-15UMHT538RJDGN99U86GVLYYTJ4SS7T7U6W80NY63R5276CHEN3JSCCHMJM"
#   }
# }


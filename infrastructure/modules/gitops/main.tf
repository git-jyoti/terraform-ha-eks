resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = var.namespace
  create_namespace = true
  version          = var.chart_version

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # HA settings for production
  set {
    name  = "controller.replicas"
    value = "2"
  }

  set {
    name  = "server.replicas"
    value = "2"
  }
}

resource "kubernetes_network_policy" "backend_ingress" {
  metadata {
    name      = "backend-ingress-from-frontend"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "backend"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "frontend"
          }
        }
      }
      ports {
        port     = var.backend_port
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "db_ingress" {
  metadata {
    name      = "db-ingress-from-backend"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = {
        app = "db"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            app = "backend"
          }
        }
      }
      ports {
        port     = var.db_port
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

resource "kubernetes_network_policy" "default_deny_all" {
  metadata {
    name      = "default-deny-all"
    namespace = var.namespace
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

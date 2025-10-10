variable "argocd_namespace" {
  description = "Namespace для розгортання ArgoCD"
  type        = string
  default     = "infra-tools"
}

variable "argocd_chart_version" {
  description = "Версія ArgoCD Helm чарту"
  type        = string
  default     = "7.4.0"
}

variable "argocd_server_service_type" {
  description = "Тип сервісу для ArgoCD Server"
  type        = string
  default     = "ClusterIP"
}


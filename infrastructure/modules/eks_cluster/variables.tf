variable "cluster_name" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.32"
}

variable "subnet_ids" {
  type = list(string)
}

variable "cluster_sg_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

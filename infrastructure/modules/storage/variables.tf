variable "project_name" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "efs_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

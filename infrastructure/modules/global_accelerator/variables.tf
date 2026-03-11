variable "project_name" {
  type = string
}

variable "region_a" {
  type = string
}

variable "region_b" {
  type = string
}

variable "alb_arn_a" {
  type = string
}

variable "alb_arn_b" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "backend_port" {
  type    = number
  default = 8080
}

variable "db_port" {
  type    = number
  default = 5432
}

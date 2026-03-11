variable "project_name" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "15.4"
}

variable "db_name" {
  type    = string
  default = "myappdb"
}

variable "is_global_cluster" {
  type    = bool
  default = false
}

variable "global_cluster_id" {
  type    = string
  default = null
}

variable "master_username" {
  type    = string
  default = "adminuser"
}

variable "master_password" {
  type    = string
  default = "securepassword123" # Use secret management in real life
}

variable "db_subnet_group_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "instance_class" {
  type    = string
  default = "db.r6g.large"
}

variable "tags" {
  type    = map(string)
  default = {}
}

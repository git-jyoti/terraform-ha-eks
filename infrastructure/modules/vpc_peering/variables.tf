variable "vpc_peering_connection_id" {
  type    = string
  default = ""
}

variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "peer_vpc_id" {
  type = string
}

variable "peer_region" {
  type = string
}

variable "peer_vpc_cidr" {
  type = string
}

variable "vpc_route_table_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}

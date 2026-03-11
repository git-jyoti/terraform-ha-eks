variable "domain_name" {
  type = string
}

variable "subdomain" {
  type = string
}

variable "lb_dns_name" {
  type = string
}

variable "lb_zone_id" {
  type = string
}

variable "region" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

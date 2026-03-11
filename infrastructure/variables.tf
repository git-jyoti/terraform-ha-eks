variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ha-eks"
}

variable "regions" {
  description = "AWS regions for deployment"
  type        = map(string)
  default = {
    a = "ap-south-1"
    b = "ap-southeast-1"
  }
}

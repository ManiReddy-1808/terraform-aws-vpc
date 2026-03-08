variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "vpc_tags" {
  type = map
  default = {} # User can pass his own variables
}

variable "igw_tags" {
  type = map
  default = {} # User can pass his own variables
}
data "aws_availability_zones" "availabile" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}
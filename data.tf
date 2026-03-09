data "aws_availability_zones" "availabile" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

 # Created automatically when we create VPC. Get all route tables of default VPC. 
data "aws_route_tables" "default" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "association.main" # Get only main route table of default VPC
    values = ["true"]
  }
}
output "azs_info" {
  value = data.aws_availability_zones.availabile
}

output "vpc_id" {
  value = aws_vpc.main.id
}
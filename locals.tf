locals {
  common_tags = {
    Project = var.project
    Environment = var.environment
    Terraform = true
  }
  vpc_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}" # roboshop-dev
    },
    var.vpc_tags
  )

  igw_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}" # roboshop-dev
    },
    var.igw_tags
  )

  az_names = slice(data.aws_availability_zones.availabile.names, 0, 2)

}
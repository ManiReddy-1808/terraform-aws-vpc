resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id  # IGW is associating with above VPC

  tags = local.igw_final_tags
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet-cidr)
  vpc_id            = aws_vpc.main.id 
  cidr_block        = var.public_subnet-cidr[count.index]   # Get 1st public subnet ID
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true # Optional: automatically assign public IPs

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-public-us-east-1a/1b
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subnet_tags # User can pass his own tags for public subnet
  )
}
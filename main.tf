resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" { # IGW (ARCH) is associating with above VPC
  vpc_id = aws_vpc.main.id  

  tags = local.igw_final_tags
}

# Below are SUBNET TAGS ==============
resource "aws_subnet" "public" {
  count = length(var.public_subnet-cidr)
  vpc_id            = aws_vpc.main.id 
  cidr_block        = var.public_subnet-cidr[count.index]   # Get 1st public subnet ID
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true # By default value id false.

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-public-us-east-1a/1b
        Name = "${var.project}-${var.environment}-public-${local.az_names[count.index]}"
    },
    var.public_subnet_tags # User can pass his own tags for public subnet
  )
}

# Private Subnet tags
resource "aws_subnet" "private" {
  count = length(var.private_subnet-cidr)
  vpc_id            = aws_vpc.main.id 
  cidr_block        = var.private_subnet-cidr[count.index]   # Get 1st private subnet ID
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-private-us-east-1a/1b
        Name = "${var.project}-${var.environment}-private-${local.az_names[count.index]}"
    },
    var.private_subnet_tags # User can pass his own tags for private subnet
  )
}

# Database Subnet tags
resource "aws_subnet" "database" {
  count = length(var.database_subnet-cidr)
  vpc_id            = aws_vpc.main.id 
  cidr_block        = var.database_subnet-cidr[count.index]   # Get 1st private subnet ID
  availability_zone = local.az_names[count.index]

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-database-us-east-1a/1b
        Name = "${var.project}-${var.environment}-database-${local.az_names[count.index]}"
    },
    var.database_subnet_tags # User can pass his own tags for private subnet
  )
}
# Below are ROUTE TABLE'S ==========

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-public
        Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-private
        Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {   # roboshop-dev-database
        Name = "${var.project}-${var.environment}-database"
    },
    var.database_route_table_tags
  )
}

# Below are PUBLIC ROUTES to IGW (To expose externally)
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Creating NAT Gateway for private/database subnet to route traffic to Internet via elastic IP (EIP)
resource "aws_eip" "nat" { 
  domain                    = "vpc"
  tags = merge(
    local.common_tags,
    {   # roboshop-dev-nat
        Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )  
}

resource "aws_nat_gateway" "main" { # NAT Gateway needs Elastic IP (EIP) to route traffic to Internet
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Creating NAT in public-us-east-1a
  tags = merge(
  local.common_tags,
  {   # roboshop-dev-nat
      Name = "${var.project}-${var.environment}-nat"
  },
  var.nat_gateway_tags
)
  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

resource "aws_route" "private" { # Private subnet will route traffic to Internet via NAT Gateway
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "database" { # Database subnet will route traffic to Internet via NAT Gateway
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet-cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet-cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count = length(var.database_subnet-cidr)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}
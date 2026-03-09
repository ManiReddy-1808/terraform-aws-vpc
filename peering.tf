# Peering request from roboshop-dev to --> default VPC
resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1 : 0 # 1 is true then create peering connection
  
  # Acceptor is default VPC
  peer_vpc_id   = data.aws_vpc.default.id 
  
   # Requester is we created (roboshop-dev)
  vpc_id        = aws_vpc.main.id
  auto_accept = true # Bcz we are in same account

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-default"
    }
  )
}

# Below is route from roboshop-dev to default VPC. 
# route created in public route table of roboshop-dev VPC.
resource "aws_route" "public_peering" { 
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id # --> to get 1st peering connection ID 
}

# route in private route table of roboshop-dev VPC to default VPC.
resource "aws_route" "private_peering" { 
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# route in database route table of roboshop-dev VPC to default VPC.
resource "aws_route" "database_peering" { 
  count = var.is_peering_required ? 1 : 0
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# Below is route from default VPC to roboshop-dev. route created in main route table of default VPC.
resource "aws_route" "default_peering" {
  count = var.is_peering_required ? 1 : 0
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr
  vpc_peering_connection_id  = aws_vpc_peering_connection.default[count.index].id
}
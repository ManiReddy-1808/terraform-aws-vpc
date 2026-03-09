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
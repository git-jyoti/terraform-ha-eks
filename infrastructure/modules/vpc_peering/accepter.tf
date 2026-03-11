# Accepter side (Singapore)
resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = var.vpc_peering_connection_id
  auto_accept               = true

  tags = merge(var.tags, {
    Name = "${var.project_name}-peering-accepter"
  })
}

# Routes for Accepter VPC
resource "aws_route" "accepter" {
  count                     = length(var.vpc_route_table_ids)
  route_table_id            = var.vpc_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = var.vpc_peering_connection_id
}

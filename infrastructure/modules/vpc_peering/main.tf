# Requester side (Mumbai)
resource "aws_vpc_peering_connection" "this" {
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.vpc_id
  peer_region   = var.peer_region
  auto_accept   = false

  tags = merge(var.tags, {
    Name = "${var.project_name}-peering-to-${var.peer_region}"
  })
}

# Routes for Requester VPC
resource "aws_route" "requester" {
  count                     = length(var.vpc_route_table_ids)
  route_table_id            = var.vpc_route_table_ids[count.index]
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

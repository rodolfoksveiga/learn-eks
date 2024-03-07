resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat-gateway.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "RouteTablePrivate"
    Resource = "Network"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.internet-gateway.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "RouteTablePublic"
    Resource = "Network"
  }
}

resource "aws_route_table_association" "private-table-association-a" {
  subnet_id      = aws_subnet.subnet-private-a.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "public-table-association-a" {
  subnet_id      = aws_subnet.subnet-public-a.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "private-table-association-b" {
  subnet_id      = aws_subnet.subnet-private-b.id
  route_table_id = aws_route_table.private-route-table.id
}

resource "aws_route_table_association" "public-table-association-b" {
  subnet_id      = aws_subnet.subnet-public-b.id
  route_table_id = aws_route_table.public-route-table.id
}

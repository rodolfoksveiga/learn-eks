resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "InternetGateway"
    Resource = "Gateway"
  }
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Contact = "${var.contact}"
    Project = "${var.project}"
    Name    = "Eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet-public-a.id

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "NatGateway"
    Resource = "Gateway"
  }

  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Owner = "${var.owner}"
    Name  = "InternetGateway"
  }
}

resource "aws_eip" "eip" {
  vpc = true

  tags = {
    Owner = "${var.owner}"
    Name  = "Eip"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet-public-a.id

  tags = {
    Owner = "${var.owner}"
    Name  = "NatGateway"
  }

  depends_on = [aws_internet_gateway.internet-gateway]
}

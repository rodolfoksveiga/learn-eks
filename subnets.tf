resource "aws_subnet" "subnet-private-a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "${var.region}a"

  tags = {
    Owner                             = "${var.owner}"
    Name                              = "SubnetPrivateA"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "subnet-public-a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Owner                        = "${var.owner}"
    Name                         = "SubnetPublicA"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_subnet" "subnet-private-b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "${var.region}b"

  tags = {
    Owner                             = "${var.owner}"
    Name                              = "SubnetPrivateB"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_subnet" "subnet-public-b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Owner                        = "${var.owner}"
    Name                         = "SubnetPublicB"
    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}

resource "aws_vpc" "vpc" {
  tags = {
    Owner = "${var.owner}"
    Name  = "Vpc"
  }

  cidr_block = "10.0.0.0/16"
}

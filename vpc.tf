resource "aws_vpc" "vpc" {
  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "Vpc"
    Resource = "Network"
  }

  cidr_block = "10.0.0.0/16"

  enable_dns_hostnames = true
}

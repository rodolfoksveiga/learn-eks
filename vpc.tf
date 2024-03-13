locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = ["${var.region}a", "${var.region}b"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5"

  name = "${var.owner}-vpc"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 5, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 5, k + 5)]

  database_subnets             = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 64)]
  create_database_subnet_group = true

  elasticache_subnets             = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 128)]
  create_elasticache_subnet_group = true

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true

  public_subnet_tags = {
    Name                     = "PublicSubnet"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    Name                              = "PrivateSubnet"
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    Name        = "Vpc"
    Resource    = "Network"
    Environment = var.env
  }
}

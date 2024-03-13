module "rabbitmq_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1"

  name   = "${var.owner}-rabbitmq-security-group"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      description = "Allow all ingress traffic within the VPC"
      from_port   = 5672
      to_port     = 5672
      protocol    = "tcp"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  egress_with_cidr_blocks = [
    {
      description = "Allow all egress traffic within the VPC"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = {
    Name        = "RabbitMqSG"
    Module      = "SecurityGroup"
    Environment = var.env
  }
}

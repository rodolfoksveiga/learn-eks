resource "aws_mq_configuration" "rabbitmq-config" {
  name        = "${var.owner}-rabbitmq-config"
  description = "RabbitMQ Configuration"

  engine_type    = "RabbitMQ"
  engine_version = "3.11.20"

  data = <<DATA
    consumer_timeout = 1800000
  DATA

  tags = {
    Name     = "RabbitMqConfig"
    Resource = "RabbitMq"
  }
}

resource "aws_mq_broker" "rabbitmq-broker" {
  broker_name = "${var.owner}-rabbitmq-broker"

  configuration {
    id       = aws_mq_configuration.rabbitmq-config.id
    revision = aws_mq_configuration.rabbitmq-config.latest_revision
  }

  engine_type        = "RabbitMQ"
  engine_version     = "3.11.20"
  host_instance_type = "mq.m5.large"

  deployment_mode = "CLUSTER_MULTI_AZ"

  publicly_accessible = false

  subnet_ids      = module.vpc.private_subnets
  security_groups = [module.rabbitmq_security_group.security_group_id]

  user {
    username = "admin"
    password = "adminpassword"
  }

  tags = {
    Name     = "RabbitMqBroker"
    Resource = "RabbitMq"
  }
}

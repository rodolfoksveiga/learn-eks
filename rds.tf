module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.5"

  identifier = "${var.owner}-rds-instance"

  family               = "mysql8.0"
  engine               = "mysql"
  engine_version       = "8.0"
  major_engine_version = "8.0"

  instance_class    = "db.t3.micro"
  allocated_storage = 5

  # connect to mysql with the following command
  ## docker
  ### docker run -it --rm --name mysql mysql:8.0 mysql -h ${DB_ENDPOINT} -D shopware -u admin -p
  ## kubernetes
  ### kubectl run temp-pod --image mysql:8.0 -it --rm --restart=Never -- /bin/bash
  ### mysql -h ${DB_ENDPOINT} -D shopware -u admin -p
  db_name  = "shopware"
  username = "admin"
  port     = "3306"

  iam_database_authentication_enabled = true

  vpc_security_group_ids = [module.rds_security_group.security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group
  multi_az               = false

  create_db_parameter_group = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  create_cloudwatch_log_group     = true
  enabled_cloudwatch_logs_exports = ["error"]

  tags = {
    Name        = "Instance"
    Module      = "Rds"
    Environment = var.env
  }
}

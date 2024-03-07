resource "aws_db_subnet_group" "db-subnet-group" {
  name = "rodox-db-subnet-group"

  subnet_ids = [
    aws_subnet.subnet-private-a.id,
    aws_subnet.subnet-private-b.id
  ]

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "DbSecurityGroup"
    Resource = "Rds"
  }
}

resource "aws_security_group" "rds-security-group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Ingress All"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Egress All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "RdsSecurityGroup"
    Resource = "Rds"
  }
}

## create rds instance
resource "aws_db_instance" "rds-instance" {
  identifier = "rds-instance"

  engine         = "mysql"
  engine_version = "5.7"
  instance_class = "db.t3.micro"

  storage_type            = "gp2"
  allocated_storage       = 20
  max_allocated_storage   = 1000
  skip_final_snapshot     = true
  backup_retention_period = 7
  deletion_protection     = false

  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.name
  vpc_security_group_ids = [aws_security_group.rds-security-group.id]
  multi_az               = false
  publicly_accessible    = false

  # connect to the database with the following command
  ## docker run -it --rm --name rds-instance mysql:8.0 mysql -h ${DB_ENDPOINT} -D mydb -u admin -p
  name                 = "mydb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql5.7"

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "RdsInstance"
    Resource = "Rds"
  }
}

output "rodox-rds-instance-endpoint" {
  description = "RDS Instance Endpoint"
  value       = aws_db_instance.rds-instance.endpoint
}

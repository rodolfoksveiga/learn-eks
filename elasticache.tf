resource "aws_elasticache_subnet_group" "elasticache-subnet-group" {
  name = "elasticache-subnet-group"

  subnet_ids = [
    aws_subnet.subnet-private-a.id,
    aws_subnet.subnet-private-b.id
  ]

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "ElasticacheSubnetGroup"
    Resource = "Elasticache"
  }
}

resource "aws_elasticache_replication_group" "elasticache-replication-group" {
  replication_group_id          = "elasticache-replication-group"
  replication_group_description = "ElastiCache Replication Group"

  node_type            = "cache.t3.micro"
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name = aws_elasticache_subnet_group.elasticache-subnet-group.name

  automatic_failover_enabled = true
  multi_az_enabled           = false

  cluster_mode {
    num_node_groups         = 1
    replicas_per_node_group = 2
  }

  tags = {
    Contact  = "${var.contact}"
    Project  = "${var.project}"
    Name     = "ElasticacheReplicationGroup"
    Resource = "Elasticache"
  }
}

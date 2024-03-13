resource "aws_elasticache_cluster" "redis-cluster" {
  cluster_id = "${var.owner}-redis-cluster"

  node_type       = "cache.t3.micro"
  num_cache_nodes = 1

  # connect to redis with the following command
  ## docker
  ### docker run -it --rm --name redis redis:7.0 redis-cli -h ${REDIS_ENDPOINT} -p 6379
  ## kubernetes
  ### kubectl run temp-pod --image redis:7.0 -it --rm --restart=Never -- /bin/bash
  ### redis-cli -h ${REDIS_ENDPOINT} -p 6379
  engine               = "redis"
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = module.vpc.elasticache_subnet_group
  security_group_ids = [module.redis_security_group.security_group_id]

  tags = {
    Name     = "RedisCluster"
    Resource = "Redis"
  }
}

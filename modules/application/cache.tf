resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = "${var.environment}-redis"
  engine               = "redis"
  node_type            = var.redis_instance_type
  num_cache_nodes      = 1
  parameter_group_name = "default.redis3.2"
  engine_version       = "3.2.10"
  port                 = 6379
  subnet_group_name    = module.vpc.elasticache_subnet_group_name
  security_group_ids   = [aws_security_group.cache_to_app_sg.id]

  tags = {
      Environment = var.environment
  }
}




resource "aws_security_group" "cache_to_app_sg" {
    name = "${var.environment}-cache-app"
    description = "Allow traffic from main application to cache via Redis"
    vpc_id = module.vpc.vpc_id
    revoke_rules_on_delete = true

    ingress {
        description      = "TCP from Application to Cache"
        from_port        = 6379
        to_port          = 6379
        protocol         = "tcp"
        cidr_blocks      = module.vpc.private_subnets_cidr_blocks
    }

    egress {
        description      = "TCP from Cache to Application"
        from_port        = 6379
        to_port          = 6379
        protocol         = "tcp"
        cidr_blocks      = module.vpc.private_subnets_cidr_blocks
    }


    tags = {
        Environment = "${var.environment}"
    }
}
/* Networking */

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.16.0"

  name = "${var.environment}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  elasticache_subnet_group_name = "${var.environment}-elasticache-subnet-group"
  elasticache_subnets = ["10.0.131.0/24", "10.0.132.0/24", "10.0.133.0/24"]

  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  create_database_subnet_group = true
  database_subnet_group_name = "${var.environment}-db-subnet-group"
  create_database_subnet_route_table = true
  create_elasticache_subnet_route_table = true
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Environment = "${var.environment}"
  }
}
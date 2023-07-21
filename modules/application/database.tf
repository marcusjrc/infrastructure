module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.1.0" 

  identifier = "${var.environment}-db"

  engine            = "postgres"
  engine_version    = "14.3"
  instance_class    = var.rds_instance_type
  allocated_storage = 20

  db_name  = "application"
  username = "main_user"
  port     = "5432"

  iam_database_authentication_enabled = false

  vpc_security_group_ids = [aws_security_group.database_to_app_sg.id]
  db_subnet_group_name   = module.vpc.database_subnet_group_name

  maintenance_window = "Mon:00:00-Mon:03:00"

  password = var.db_password
  create_random_password = false

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically
  monitoring_interval = "0"
  monitoring_role_name = "${var.environment}-db Monitoring Role"
  create_monitoring_role = false

  tags = {
    Environment = "${var.environment}"
    Backup = true
  }

  subnet_ids = module.vpc.database_subnets
  # DB parameter group
  family = "postgres14"

  # DB option group
  major_engine_version = "14"

  # Database Deletion Protection
  deletion_protection = false
}


resource "aws_security_group" "database_to_app_sg" {
    name = "${var.environment}-db-app"
    description = "Allow traffic from main application to database via Postgres"
    revoke_rules_on_delete = true
    vpc_id = module.vpc.vpc_id

    ingress {
        description      = "TCP from Application to DB"
        from_port        = 5432
        to_port          = 5432
        protocol         = "tcp"
        cidr_blocks      = [module.vpc.vpc_cidr_block]
    }


    tags = {
        Environment = "${var.environment}"
    }
}
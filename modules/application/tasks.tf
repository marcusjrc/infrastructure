resource "aws_cloudwatch_log_group" "backend-log-group" {
  name_prefix       = "${var.environment}-backend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "worker-log-group" {
  name_prefix       = "${var.environment}-worker"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "nginx-log-group" {
  name_prefix       = "${var.environment}-nginx"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "backend" {
  family = "backend"
  container_definitions = <<EOF
[
  {
    "name": "backend",
    "image": "${aws_ecr_repository.backend.repository_url}:backend",
    "cpu": 512,
    "memoryReservation": 200,
    "essential": true,
    "environment": [
      {"name": "BACKEND_CONTAINER_TYPE", "value": "web"},
      {"name": "DOMAIN", "value": "${var.domain}"},
      {"name": "REGION", "value": "${var.region}"},
      {"name": "DB_PASSWORD", "value": "${var.db_password}"},
      {"name": "DB_HOST", "value": "${module.db.db_instance_address}"},
      {"name": "DB_USERNAME", "value": "${module.db.db_instance_username}"},
      {"name": "DB_NAME", "value": "${module.db.db_instance_name}"},
      {"name": "REDIS_URL", "value": "redis://${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}"},
      {"name": "STATIC_BUCKET_NAME", "value": "${aws_s3_bucket.static.id}"},
      {"name": "MEDIA_BUCKET_NAME", "value": "${aws_s3_bucket.media.id}"},
      {"name": "AWS_ACCESS_KEY_ID", "value": "${var.aws_access_key_id}"},
      {"name": "AWS_SECRET_ACCESS_KEY", "value": "${var.aws_secret_access_key}"}
    ],
    "portMappings": [
        {
          "containerPort": 8002,
          "hostPort": 8002
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.backend-log-group.name}",
        "awslogs-stream-prefix": "ec2"
      }
    }
  },
    {
    "name": "worker",
    "image": "${aws_ecr_repository.backend.repository_url}:backend",
    "cpu": 512,
    "memoryReservation": 200,
    "essential": true,
    "environment": [
      {"name": "BACKEND_CONTAINER_TYPE", "value": "worker"},
      {"name": "DOMAIN", "value": "${var.domain}"},
      {"name": "REGION", "value": "${var.region}"},
      {"name": "DB_PASSWORD", "value": "${var.db_password}"},
      {"name": "DB_HOST", "value": "${module.db.db_instance_address}"},
      {"name": "DB_USERNAME", "value": "${module.db.db_instance_username}"},
      {"name": "DB_NAME", "value": "${module.db.db_instance_name}"},
      {"name": "REDIS_URL", "value": "redis://${aws_elasticache_cluster.redis_cache.cache_nodes.0.address}"},
      {"name": "STATIC_BUCKET_NAME", "value": "${aws_s3_bucket.static.id}"},
      {"name": "MEDIA_BUCKET_NAME", "value": "${aws_s3_bucket.media.id}"},
      {"name": "AWS_ACCESS_KEY_ID", "value": "${var.aws_access_key_id}"},
      {"name": "AWS_SECRET_ACCESS_KEY", "value": "${var.aws_secret_access_key}"}
    ],
    "portMappings": [
        {
          "containerPort": 8002,
          "hostPort": 8003
        }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.worker-log-group.name}",
        "awslogs-stream-prefix": "ec2"
      }
    }
  },
  {
    "name": "nginx-reverse-proxy",
    "image": "${aws_ecr_repository.nginx-reverse-proxy.repository_url}:latest",
    "memoryReservation": 128,
    "cpu": 1024,
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.nginx-log-group.name}",
        "awslogs-stream-prefix": "ec2"
      }
    },
    "links": [
      "backend"
    ],
    "portMappings": [
         {
           "containerPort": 80,
           "hostPort": 80
         }
    ]
  }
]
EOF
}

resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = module.ecs.cluster_id
  task_definition = aws_ecs_task_definition.backend.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  force_new_deployment = true

  load_balancer {
    target_group_arn = aws_lb_target_group.backend_alb_target.arn
    container_name   = "nginx-reverse-proxy"
    container_port   = 80
  }
}






/* Compute */


locals {
  cluster_name = "${var.environment}-application-ecs"
  user_data = <<-EOT
    #!/bin/bash
    cat <<'EOF' >> /etc/ecs/ecs.config
    ECS_CLUSTER=${local.cluster_name}
    ECS_LOGLEVEL=debug
    EOF
  EOT
}

module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.environment}-application-ecs"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "${var.environment}-ecs-logs"
      }
    }
  }

  autoscaling_capacity_providers = {
    one = {
      create_before_destroy          = true
      auto_scaling_group_arn         = module.backend_autoscaling.autoscaling_group_arn
      managed_termination_protection = "ENABLED"

      managed_scaling = {
        maximum_scaling_step_size = 1
        minimum_scaling_step_size = 1
        status                    = "ENABLED"
        target_capacity           = 60
      }

      default_capacity_provider_strategy = {
        weight = 60
        base   = 20
      }
    }
  }

  tags = {
    Environment = "${var.environment}"
  }
}


module "backend_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name = local.cluster_name

  image_id      = var.ecs_ami_image
  instance_type = var.ecs_instance_type
  user_data     = base64encode(local.user_data)


  security_groups                 = [module.backend_autoscaling_sg.security_group_id]
  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = "${var.environment}-backend-autoscaling-role"
  iam_role_description        = "ECS role for Backend Autoscaling group"
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  vpc_zone_identifier = module.vpc.private_subnets
  health_check_type   = "EC2"
  min_size            = var.backend_auto_scaling_min
  max_size            = var.backend_auto_scaling_max
  desired_capacity    = 1

  # https://github.com/hashicorp/terraform-provider-aws/issues/12582
  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  # Required for  managed_termination_protection = "ENABLED"
  protect_from_scale_in = true

  tags = {
    Environment = var.environment
  }
}

module "backend_autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.environment}-backend-autoscaling-sg"
  description = "Autoscaling group security group for backend autoscaling. Set to allow all HTTP traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
  }
}
variable "region" {
    description = "AWS Region to deploy to"
    type = string
    default = "us-west-2"
}

variable "environment" {
    description = "Environment name, i.e. dev, qa, us-prod. Should be lowercase"
    type = string
    default = "dev"
}

variable "db_password" {
    description = "Password for RDS postgres"
    type = string
}

variable "app_name" {
    description = "Application name. Should be lowercase"
    type = string
    default = "fire"
}

variable "domain" {
    description = "Domain"
    type = string
}

variable "aws_access_key_id" {
    description = "AWS Access Key id for S3 bucket access"
    type = string
}

variable "aws_secret_access_key" {
    description = "AWS Secret Access key for S3 bucket access"
    type = string
}

variable "backend_auto_scaling_min" {
    description = "Minimum ec2 instances for backend auto-scaling group"
    type = string
    default = 1
}

variable "backend_auto_scaling_max" {
    description = "Maximum ec2 instances for backend auto-scaling group"
    type = string
    default = 1
}

variable "ecs_ami_image" {
    description = "AMI used for EC2 instances on ECS"
    type = string
    default = "ami-005b5f3941c234694"
}

variable "ecs_instance_type" {
    description = "Instance type used by ECS cluster"
    type = string
    default = "t3.micro"
}

variable "rds_instance_type" {
    description = "Instance type used by RDS"
    type = string
    default = "db.t3.micro"
}

variable "redis_instance_type" {
    description = "Instance type used by redis"
    type = string
    default = "cache.t3.micro"
}
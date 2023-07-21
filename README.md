# Application Infrastructure-as-code

This sets up the infrastructure for our application. It consists of a single module named:

**application**

The application module has been split into its different requirements, including:

- **alb.tf** - public application load balancer for backend
- **cache.tf** - elasticache redis cluster
- **cdn.tf** - Cloudfront distribution for application
- **certificates.tf** - AWS managed certificates for SSL - this is deployed in us-east-1 for Cloudfront requirements
- **compute.tf** - ecs & auto-scaling groups
- **containers.tf** - ecr container registrations
- **database.tf** - postgres database
- **dns.tf** - Route 53 records for domain
- **networking.tf** - vpc networking setup
- **storage.tf** - s3 buckets
- **tasks.tf** - ecs tasks


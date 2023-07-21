
resource "aws_ecr_repository" "backend" {
    name  = "backend"
}

resource "aws_ecr_repository" "nginx-reverse-proxy" {
    name  = "nginx-reverse-proxy"
}
output "load_balancer_ip" {
  value = aws_lb.laravel_fargate.dns_name
}
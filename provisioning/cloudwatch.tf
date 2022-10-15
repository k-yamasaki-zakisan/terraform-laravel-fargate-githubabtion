resource "aws_cloudwatch_log_group" "laravel_fargate_log_group" {
  name = "${local.app_name}-log-group"
}
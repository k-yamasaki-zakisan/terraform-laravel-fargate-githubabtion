resource "aws_cloudwatch_log_group" "laravel_fargate_log_group" {
  name              = "${local.APP_NAME}-log-group"
  retention_in_days = 1
}
resource "aws_ssm_parameter" "db_password" {
  name  = "/${local.APP_NAME}/db_password"
  type  = "SecureString"
  value = "dummy"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/${local.APP_NAME}/db_username"
  type  = "SecureString"
  value = "dummy"
  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_ssm_parameter" "db_host" {
  name  = "/${local.APP_NAME}/db_host"
  type  = "SecureString"
  value = "postgresql://${aws_ssm_parameter.db_username.value}:${aws_ssm_parameter.db_password.value}@${aws_db_instance.survey_db.endpoint}/${aws_db_instance.survey_db.db_name}"
}

resource "aws_ssm_parameter" "app_key" {
  name  = "/${local.APP_NAME}/app_key"
  type  = "SecureString"
  value = "dummy"
  lifecycle {
    ignore_changes = [value]
  }
}
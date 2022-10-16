resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "${local.APP_NAME}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn

  container_definitions = <<DEFINITION
[
  {
    "image": "251392685720.dkr.ecr.ap-northeast-1.amazonaws.com/laravel-fargate:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "${local.APP_NAME}-app",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      {
        "name": "APP_ENV",
        "value": "production"
      },
      {
        "name": "DB_PORT",
        "value": "${aws_db_instance.survey_db.port}"
      },
      {
        "name": "DB_CONNECTION",
        "value": "pgsql"
      },
      {
        "name": "DB_DATABASE",
        "value": "${aws_db_instance.survey_db.name}"
      },
      {
        "name": "LOG_CHANNEL",
        "value": "stderr"
      }
    ],
    "secrets": [
      {
        "name": "APP_KEY",
        "valueFrom": "${aws_ssm_parameter.app_key.arn}"
      },
      {
        "name": "DB_HOST",
        "valueFrom": "${aws_ssm_parameter.db_host.arn}"
      },
      {
        "name": "DB_USERNAME",
        "valueFrom": "${aws_ssm_parameter.db_username.arn}"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_ssm_parameter.db_password.arn}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${local.AWS_DEFAULT_REGION}",
        "awslogs-group": "${aws_cloudwatch_log_group.laravel_fargate_log_group.name}",
        "awslogs-stream-prefix": "ecs-container-log-stream",
        "awslogs-datetime-format": "%Y-%m-%d %H:%M:%S"
      }
    }
  }
]
DEFINITION
}

resource "aws_security_group" "ecs_security_group" {
  name        = "${local.APP_NAME}-task-security-group"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_ecs_cluster" "main" {
  name = "${local.APP_NAME}-cluster"
}


resource "aws_ecs_service" "ecs_service" {
  name            = "${local.APP_NAME}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.ecs_security_group.id]
    subnets         = aws_subnet.private.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.laravel_fargate.id
    container_name   = "${local.APP_NAME}-app"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.http]
}

data "aws_iam_policy_document" "ecs_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_tasks_execution_secret_role" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]
    resources = [
      # "/${local.APP_NAME}/*"
      aws_ssm_parameter.db_password.arn,
      aws_ssm_parameter.db_username.arn,
      aws_ssm_parameter.db_host.arn,
      aws_ssm_parameter.app_key.arn,
    ]
  }
}

resource "aws_iam_policy" "secret-policy" {
  name        = "${local.APP_NAME}-secret-policy"
  description = "${local.APP_NAME} secret policy"
  policy = data.aws_iam_policy_document.ecs_tasks_execution_secret_role.json
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${local.APP_NAME}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_execution_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  ]
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_security_group" "private-db-sg" {
  name = "${local.app_name}-private-db-sg"
  vpc_id = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "public-db-sg"
  }
}

resource "aws_security_group_rule" "database_sg_rule" {
  security_group_id = aws_security_group.private-db-sg.id

  type = "ingress"

  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  source_security_group_id = aws_security_group.ecs_security_group.id
}

resource "aws_db_instance" "survey_db" {
  db_name                 = "survey_db"
  identifier              = "${local.app_name}-survey-db"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "12.8"
  instance_class          = "db.t3.micro"
  username                = aws_ssm_parameter.db_username.value
  password                = aws_ssm_parameter.db_password.value
  vpc_security_group_ids  = [aws_security_group.private-db-sg.id]
  db_subnet_group_name = aws_db_subnet_group.private-db.name
  skip_final_snapshot = true
}
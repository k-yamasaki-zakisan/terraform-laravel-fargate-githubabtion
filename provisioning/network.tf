data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = local.APP_NAME
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, 2 + count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  tags = {
    Type = "${local.APP_NAME}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    Type = "${local.APP_NAME}-private-subnet"
  }
}

resource "aws_subnet" "private-db" {
  count             = 2
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, 10 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    Type = "${local.APP_NAME}-private-db-subnet"
  }
}

resource "aws_db_subnet_group" "private-db" {
  name        = "${local.APP_NAME}-private-db"
  subnet_ids  = aws_subnet.private-db.*.id
  tags = {
    Name = "${local.APP_NAME}-private-db-subnet-group"
  }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

resource "aws_eip" "gateway" {
  count      = 2
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

resource "aws_nat_gateway" "gateway" {
  count         = 2
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = element(aws_eip.gateway.*.id, count.index)
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gateway.*.id, count.index)
  }
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_security_group" "lb" {
  name        = "${local.APP_NAME}-security-group"
  description = "${local.APP_NAME} alb rule based routing"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_security_group_rule" "alb_http" {
#   from_port         = 80
#   protocol          = "tcp"
#   security_group_id = aws_security_group.lb.id
#   to_port           = 80
#   type              = "ingress"
#   cidr_blocks = ["0.0.0.0/0"]
# }

# resource "aws_security_group_rule" "alb_https" {
#   from_port         = 443
#   protocol          = "tcp"
#   security_group_id = aws_security_group.lb.id
#   to_port           = 443
#   type              = "ingress"
#   cidr_blocks = ["0.0.0.0/0"]
# }

resource "aws_lb" "laravel_fargate" {
  name            = "${local.APP_NAME}-lb"
  subnets         = aws_subnet.public.*.id
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb.id]
}

resource "aws_lb_target_group" "laravel_fargate" {
  name        = "${local.APP_NAME}-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.laravel_fargate.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.laravel_fargate.id
    type             = "forward"
  }
}
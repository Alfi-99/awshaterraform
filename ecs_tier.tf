# ECR Repository
resource "aws_ecr_repository" "app_repo" {
  name         = "latihan-ecs-repo"
  force_delete = true
}

# ECS Cluster
resource "aws_ecs_cluster" "main" { name = "latihan-cluster" }

# Security Group untuk ECS
resource "aws_security_group" "ecs_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "latihan-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "web-container"
    image = "${aws_ecr_repository.app_repo.repository_url}:latest"
    portMappings = [{ containerPort = 80, hostPort = 80 }]
  }])
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "latihan-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.pub[*].id
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "web-container"
    container_port   = 80
  }
}
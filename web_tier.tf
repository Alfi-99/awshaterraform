# Security Group: Web hanya bisa diakses dari ALB
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # ID Owner resmi Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_sg" {
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

# Launch Template & ASG
resource "aws_launch_template" "web" {
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data = base64encode(<<-EOF
              #!/bin/bash
              # Update dan install Apache
              apt update -y
              apt install -y apache2
              systemctl start apache2
              systemctl enable apache2

              # Mengambil Nama Availability Zone dari Metadata Instance
              AZ=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

              # Membuat file index.html kustom yang menampilkan AZ
              echo "<html>
              <head><title>Terraform HA Test</title></head>
              <body style='background-color: #f4f4f4; text-align: center; font-family: sans-serif; padding-top: 50px;'>
                <h1>Berhasil Terhubung!</h1>
                <p style='font-size: 20px;'>Server ini berjalan di Availability Zone: <strong style='color: #ff9900;'>$AZ</strong></p>
                <hr style='width: 50%;'>
                <p>Managed by Terraform</p>
              </body>
              </html>" > /var/www/html/index.html
              EOF
  )
}

resource "aws_lb" "alb" {
  name               = "terra-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.pub[*].id
}

resource "aws_lb_target_group" "tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier = aws_subnet.pub[*].id
  target_group_arns   = [aws_lb_target_group.tg.arn]
  min_size            = 2
  max_size            = 3
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}
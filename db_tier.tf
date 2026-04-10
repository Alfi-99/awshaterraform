resource "aws_db_subnet_group" "main" {
name       = "latihan-db-subnet-group-v2" # Ganti namanya di sini (tambah -v2)
  subnet_ids = aws_subnet.pub[*].id

  tags = {
    Name = "Main DB Subnet Group"
  }
}

# 1. Security Group untuk Database
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.main.id

  # Aturan masuk: Cuma boleh dari ECS dan Bastion
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id, aws_security_group.bastion_sg.id]
  }

  # Aturan keluar: Bebas
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Database Instance-nya
resource "aws_db_instance" "terradb" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "terradb"
  username               = "admin"
  password               = "admin12345"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id] # Panggil SG di atas
  skip_final_snapshot    = true
}
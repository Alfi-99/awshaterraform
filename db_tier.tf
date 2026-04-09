# 1. DB Subnet Group: Memberitahu AWS di subnet mana saja RDS boleh berjalan
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.pub[*].id 

  tags = { Name = "Main DB Subnet Group" }
}

# 2. Security Group untuk RDS
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.main.id

  # Izin dari Web Tier
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  # Izin dari Bastion Host 
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "RDS-Security-Group" }
}

# 3. RDS MySQL Instance 
resource "aws_db_instance" "terradb" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" 
  db_name              = "terradb"
  username             = "admin"
  password             = "admin12345"
  parameter_group_name = "default.mysql8.0"
  
  # Pengaturan High Availability & Keamanan
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true  
  publicly_accessible    = false 

  tags = { Name = "Main-RDS-Instance" }
}
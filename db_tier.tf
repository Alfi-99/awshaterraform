resource "aws_db_subnet_group" "db_sub" {
  name       = "terra-db-sub"
  subnet_ids = aws_subnet.pub[*].id
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

resource "aws_db_instance" "db" {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "terradb"
  username               = "admin"
  password               = "PasswordTerra2026"
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_sub.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  skip_final_snapshot    = true
}
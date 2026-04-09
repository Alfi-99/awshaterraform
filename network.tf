resource "aws_vpc" "main" {
  cidr_block = "10.30.0.0/16"
  tags       = { Name = "TERRA-VPC" }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "pub" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.30.${count.index}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  count          = 2
  subnet_id      = aws_subnet.pub[count.index].id
  route_table_id = aws_route_table.rt.id
}

# Security Group untuk Bastion (Hanya buka SSH)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Di lomba/produksi, baiknya ganti ke IP kamu saja
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance Bastion Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id 
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.pub[0].id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = "terraform-bastion"

  tags = { Name = "Bastion-Host" }
}
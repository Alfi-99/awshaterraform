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
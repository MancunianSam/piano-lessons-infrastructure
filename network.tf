resource "aws_vpc" "main" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "piano-lessons-vpc"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, local.az_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "piano-lessons-public-subnet"
  }
}

resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 12, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "piano-lessons-private-subnet"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private_association" {
  count          = local.az_count
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private[count.index].id
}

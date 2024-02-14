resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {}
}
resource "aws_internet_gateway" "main_gw" {
  vpc_id = aws_vpc.main.id

  tags = {}
}
resource "aws_route" "main_gw" {
  route_table_id = aws_vpc.main.default_route_table_id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_gw.id
}
